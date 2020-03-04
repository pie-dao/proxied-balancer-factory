import { ethers } from "@nomiclabs/buidler";
import { Signer, Wallet } from "ethers";
import chai from "chai";
import { deployContract, solidity } from "ethereum-waffle";
import { IBFactoryFactory } from "../typechain/IBFactoryFactory";
import { IPBPoolFactory } from "../typechain/IPBPoolFactory";
import { PProxiedBalancerFactoryFactory } from "../typechain/PProxiedBalancerFactoryFactory";
import { PProxiedBalancerFactory } from "../typechain/PProxiedBalancerFactory";
import { PBPoolOverridesFactory } from "../typechain/PBPoolOverridesFactory";
import { PBPoolOverrides } from "../typechain/PBPoolOverrides";
import { deployBalancerFactory } from "../utils";
import { IPBPool } from "../typechain/IPBPool";



chai.use(solidity);
const { expect } = chai;


const PLACE_HOLDER_ADDRESS = "0x0000000000000000000000000000000000000001";

describe("PProxiedBalancerFactory", () => {
    let signers: Signer[];
    let factory: PProxiedBalancerFactory;
    let overrides: PBPoolOverrides;
    let template: string;

    beforeEach(async() => {
        signers = await ethers.signers();

        const bFactoryAddress = await deployBalancerFactory(signers[0]);

        const tx = await IBFactoryFactory.connect(bFactoryAddress, signers[0]).newBPool();
        const receipt = await tx.wait(0);

        template = receipt.events[0].args[1];

        const factoryFactory = new PProxiedBalancerFactoryFactory(signers[0]);
        const overridesFactory = new PBPoolOverridesFactory(signers[0]);

        overrides = await overridesFactory.deploy();
        factory = await factoryFactory.deploy(overrides.address, template);

    });
    describe("constructor", async() => {
        it("Template should be correctly set", async() => {
            const actualTemplate = await factory.template();
            expect(actualTemplate).to.eq(template);
        });

        it("Overrides should be correctly set", async() => {
            const overridesAddress = await factory.overrides();
            expect(overridesAddress).to.eq(overrides.address);
        });
    });
    
    describe("Deploying proxied pool", async() => {
        let pool: IPBPool;
        const name = "Stable PIE";
        const symbol = "SPIE🕵🏽‍♀️";

        beforeEach(async() => {
            await factory.newProxiedPool(name, symbol);  
            const poolAddress = await factory.bPools(0);
            pool = IPBPoolFactory.connect(poolAddress, signers[0]);
        });

        it("Pool token name and symbol should be correctly overwritten", async() => {
            const actualName = await pool.name();
            const actualSymbol = await pool.symbol();

            expect(actualName).to.eq(name);
            expect(symbol).to.eq(actualSymbol);
        });

        it("Controller should be correctly setup", async() => {
            const controller = await pool.getController();
            const user = await signers[0].getAddress();
            expect(controller).to.eq(user);
        })

        it("Factory should be correctly setup", async() => {
            const factoryAddress = await pool.getFactory();
            expect(factoryAddress).to.eq(factory.address);
        })
    });
});