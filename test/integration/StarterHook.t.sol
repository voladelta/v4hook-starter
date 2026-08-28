// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {PoolSwapTest} from "@uniswap/v4-core/src/test/PoolSwapTest.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {ImmutableState} from "@uniswap/v4-periphery/src/base/ImmutableState.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";

import {EasyPosm} from "../utils/libraries/EasyPosm.sol";

import {StarterHook} from "../../src/StarterHook.sol";
import {BaseTest} from "../utils/BaseTest.sol";

contract StarterHookIntegrationTest is BaseTest {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    Currency currency0;
    Currency currency1;

    PoolKey poolKey;

    StarterHook hook;
    PoolId poolId;

    uint256 tokenId;
    int24 tickLower;
    int24 tickUpper;

    function setUp() public {
        // Deploys all required artifacts.
        deployArtifactsAndLabel();

        (currency0, currency1) = deployCurrencyPair();

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG
                    | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        bytes memory constructorArgs = abi.encode(poolManager); // Add all the necessary constructor arguments from the hook
        deployCodeTo("StarterHook.sol:StarterHook", constructorArgs, flags);
        hook = StarterHook(flags);

        // Create the pool
        poolKey = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = poolKey.toId();
        poolManager.initialize(poolKey, Constants.SQRT_PRICE_1_1);

        // Provide full-range liquidity to the pool
        tickLower = TickMath.minUsableTick(poolKey.tickSpacing);
        tickUpper = TickMath.maxUsableTick(poolKey.tickSpacing);

        uint128 liquidityAmount = 100e18;

        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
            Constants.SQRT_PRICE_1_1,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityAmount
        );

        (tokenId,) = positionManager.mint(
            poolKey,
            tickLower,
            tickUpper,
            liquidityAmount,
            amount0Expected + 1,
            amount1Expected + 1,
            address(this),
            block.timestamp,
            Constants.ZERO_BYTES
        );
    }

    function test_realPoolManagerCallsSwapCallbacks() public {
        // positions were created in setup()
        assertEq(hook.beforeAddLiquidityCount(poolId), 1);
        assertEq(hook.beforeRemoveLiquidityCount(poolId), 0);

        assertEq(hook.beforeSwapCount(poolId), 0);
        assertEq(hook.afterSwapCount(poolId), 0);

        // Perform a test swap //
        int256 amountSpecified = -1e18;
        BalanceDelta swapDelta = poolSwapRouter.swap(
            poolKey,
            SwapParams({
                zeroForOne: true, amountSpecified: amountSpecified, sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            Constants.ZERO_BYTES
        );
        // ------------------- //

        assertEq(int256(swapDelta.amount0()), amountSpecified);

        assertEq(hook.beforeSwapCount(poolId), 1);
        assertEq(hook.afterSwapCount(poolId), 1);
    }

    function test_hookPermissionsMatchAddressFlags() public view {
        Hooks.Permissions memory expected = Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });

        assertEq(keccak256(abi.encode(hook.getHookPermissions())), keccak256(abi.encode(expected)));

        uint160 expectedFlags = uint160(
            Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG
                | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
        );
        assertEq(uint160(address(hook)) & uint160((1 << 14) - 1), expectedFlags);
    }

    function test_hookPermissionsMatchHookrManifest() public view {
        string memory manifestPath = "integrations/hookr/manifest.json";
        if (!vm.exists(manifestPath)) return;

        string memory manifest = vm.readFile(manifestPath);
        Hooks.Permissions memory permissions = hook.getHookPermissions();
        string memory root = ".uniswapClassification.flags.";

        assertEq(permissions.beforeInitialize, vm.parseJsonBool(manifest, string.concat(root, "beforeInitialize")));
        assertEq(permissions.afterInitialize, vm.parseJsonBool(manifest, string.concat(root, "afterInitialize")));
        assertEq(permissions.beforeAddLiquidity, vm.parseJsonBool(manifest, string.concat(root, "beforeAddLiquidity")));
        assertEq(permissions.afterAddLiquidity, vm.parseJsonBool(manifest, string.concat(root, "afterAddLiquidity")));
        assertEq(
            permissions.beforeRemoveLiquidity, vm.parseJsonBool(manifest, string.concat(root, "beforeRemoveLiquidity"))
        );
        assertEq(
            permissions.afterRemoveLiquidity, vm.parseJsonBool(manifest, string.concat(root, "afterRemoveLiquidity"))
        );
        assertEq(permissions.beforeSwap, vm.parseJsonBool(manifest, string.concat(root, "beforeSwap")));
        assertEq(permissions.afterSwap, vm.parseJsonBool(manifest, string.concat(root, "afterSwap")));
        assertEq(permissions.beforeDonate, vm.parseJsonBool(manifest, string.concat(root, "beforeDonate")));
        assertEq(permissions.afterDonate, vm.parseJsonBool(manifest, string.concat(root, "afterDonate")));
        assertEq(
            permissions.beforeSwapReturnDelta, vm.parseJsonBool(manifest, string.concat(root, "beforeSwapReturnsDelta"))
        );
        assertEq(
            permissions.afterSwapReturnDelta, vm.parseJsonBool(manifest, string.concat(root, "afterSwapReturnsDelta"))
        );
        assertEq(
            permissions.afterAddLiquidityReturnDelta,
            vm.parseJsonBool(manifest, string.concat(root, "afterAddLiquidityReturnsDelta"))
        );
        assertEq(
            permissions.afterRemoveLiquidityReturnDelta,
            vm.parseJsonBool(manifest, string.concat(root, "afterRemoveLiquidityReturnsDelta"))
        );
    }

    function test_directSwapCallbackReverts() public {
        vm.expectRevert(ImmutableState.NotPoolManager.selector);
        hook.beforeSwap(
            address(this),
            poolKey,
            SwapParams({zeroForOne: true, amountSpecified: -1e18, sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1}),
            Constants.ZERO_BYTES
        );
    }

    function test_realPoolManagerSupportsExactInputZeroForOne() public {
        _assertSwapQuadrant(poolKey, poolId, true, -1e18, hex"010203");
    }

    function test_realPoolManagerSupportsExactInputOneForZero() public {
        _assertSwapQuadrant(poolKey, poolId, false, -1e18, Constants.ZERO_BYTES);
    }

    function test_realPoolManagerSupportsExactOutputZeroForOne() public {
        _assertSwapQuadrant(poolKey, poolId, true, 1e18, Constants.ZERO_BYTES);
    }

    function test_realPoolManagerSupportsExactOutputOneForZero() public {
        _assertSwapQuadrant(poolKey, poolId, false, 1e18, Constants.ZERO_BYTES);
    }

    function test_callbackCountsAreScopedByPoolId() public {
        PoolKey memory secondPoolKey = PoolKey(currency0, currency1, 500, 10, IHooks(hook));
        PoolId secondPoolId = secondPoolKey.toId();
        poolManager.initialize(secondPoolKey, Constants.SQRT_PRICE_1_1);

        int24 secondTickLower = TickMath.minUsableTick(secondPoolKey.tickSpacing);
        int24 secondTickUpper = TickMath.maxUsableTick(secondPoolKey.tickSpacing);
        uint128 secondLiquidity = 100e18;
        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
            Constants.SQRT_PRICE_1_1,
            TickMath.getSqrtPriceAtTick(secondTickLower),
            TickMath.getSqrtPriceAtTick(secondTickUpper),
            secondLiquidity
        );
        positionManager.mint(
            secondPoolKey,
            secondTickLower,
            secondTickUpper,
            secondLiquidity,
            amount0Expected + 1,
            amount1Expected + 1,
            address(this),
            block.timestamp,
            Constants.ZERO_BYTES
        );

        _assertSwapQuadrant(secondPoolKey, secondPoolId, true, -1e18, Constants.ZERO_BYTES);

        assertEq(hook.beforeAddLiquidityCount(poolId), 1);
        assertEq(hook.beforeAddLiquidityCount(secondPoolId), 1);
        assertEq(hook.beforeSwapCount(poolId), 0);
        assertEq(hook.afterSwapCount(poolId), 0);
    }

    function test_realPositionManagerCallsLiquidityCallbacks() public {
        // positions were created in setup()
        assertEq(hook.beforeAddLiquidityCount(poolId), 1);
        assertEq(hook.beforeRemoveLiquidityCount(poolId), 0);

        // remove liquidity
        uint256 liquidityToRemove = 1e18;
        positionManager.decreaseLiquidity(
            tokenId,
            liquidityToRemove,
            0, // Max slippage, token0
            0, // Max slippage, token1
            address(this),
            block.timestamp,
            Constants.ZERO_BYTES
        );

        assertEq(hook.beforeAddLiquidityCount(poolId), 1);
        assertEq(hook.beforeRemoveLiquidityCount(poolId), 1);
    }

    function _assertSwapQuadrant(
        PoolKey memory key,
        PoolId id,
        bool zeroForOne,
        int256 amountSpecified,
        bytes memory hookData
    ) internal {
        uint256 balance0Before = currency0.balanceOf(address(this));
        uint256 balance1Before = currency1.balanceOf(address(this));

        BalanceDelta swapDelta = poolSwapRouter.swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: amountSpecified,
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            hookData
        );

        _assertSettledBalance(balance0Before, currency0.balanceOf(address(this)), swapDelta.amount0());
        _assertSettledBalance(balance1Before, currency1.balanceOf(address(this)), swapDelta.amount1());
        assertEq(hook.beforeSwapCount(id), 1);
        assertEq(hook.afterSwapCount(id), 1);
    }

    function _assertSettledBalance(uint256 balanceBefore, uint256 balanceAfter, int128 delta) internal pure {
        if (delta < 0) {
            assertEq(balanceBefore - balanceAfter, uint256(-int256(delta)));
        } else {
            assertEq(balanceAfter - balanceBefore, uint256(int256(delta)));
        }
    }
}
