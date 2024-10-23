const { execSync } = require('child_process');
const { ethers } = require("ethers");

const RPC_URL = "https://rpc.open-campus-codex.gelato.digital";
const PRIVATE_KEY = "f0b0741c434a75204782c5dfe8b339a3718f59151399ec4bdc18fd6772a22bf0";
const chainId = 656476;

// 8월 26일 2차 배포 컨트렉트
// Vat Contract Address: 0x514066e1f24fDA9f2B379748f9C001C3475625cB
// Gem Contract Address: 0x345E902846aC3805719483d80D664ABa0B6aF40C
// GemJoin Contract Address: 0xD40588c705B99d406B048629E4D8863a2434beF5
// XSD Contract Address: 0xCef966528A867176BF3a575c9951f695e8eB77a3
// XsdJoin Contract Address: 0x42FfAe0648A84c0AC72D012402f380ab511AcBb1
// CDP Manager Contract Address: 0x0E492702CA0A2048e87A21CE3Ac7E11Be757af2b
// OneClick Contract Address: 0x949FC90364a71BE0FAB2Ce5ADEEC60aef8FFc196
// Jug Contract Address: 0x09Fd469b3036E45Dad077Df411134Fb85218678e
// Spot Contract Address: 0x92B7e50CE799e8E26dE7324b3a92e93Dbbdf554F
// DaiExitManager Contract Address:  0x82eD6Df7b8864C856e18d876e89c33F163eAc8ae

// Helper function to deploy and verify contracts
const deployAndVerify = (contractPath, constructorArgs, abiEncodeString) => {
    try {
        const deployCommand = `forge create --rpc-url ${RPC_URL} --constructor-args "${constructorArgs.join('" "')}" --private-key ${PRIVATE_KEY} ${contractPath}`;
        console.log(`Deploying ${contractPath} contract...`);
        const deployOutput = execSync(deployCommand, { stdio: 'pipe' }).toString();
        console.log("Deploy output:", deployOutput);

        const addressMatch = deployOutput.match(/Deployed to: (0x[0-9a-fA-F]{40})/);
        if (!addressMatch) {
            throw new Error("Failed to find contract address in deploy output");
        }
        const contractAddress = addressMatch[1];
        console.log(`Contract deployed at: ${contractAddress}`);

        const abiEncodedArgs = execSync(`cast abi-encode "constructor(${abiEncodeString})" "${constructorArgs.join('" "')}"`).toString().trim();
        console.log(`ABI Encoded Args: ${abiEncodedArgs}`);

        const verifyCommand = `forge verify-contract \
        --rpc-url ${RPC_URL} \
        ${contractAddress} \
        ${contractPath} \
        --verifier blockscout \
        --verifier-url https://edu-chain-testnet.blockscout.com/api/ \
        --constructor-args ${abiEncodedArgs}`;

        console.log(`Verifying ${contractPath} contract...`);
        const verifyOutput = execSync(verifyCommand, { stdio: 'pipe' });
        if (verifyOutput) {
            console.log("Verify output:", verifyOutput.toString());
        } else {
            console.log("No output from verify command. Contract might already be verified.");
        }

        return contractAddress;
    } catch (error) {
        console.error("Error during contract deployment or verification:", error.message);
        process.exit(1);
    }
};

const main = () => {

    const vatAddress = "0x514066e1f24fDA9f2B379748f9C001C3475625cB"
    // const gemAddress = "0x345E902846aC3805719483d80D664ABa0B6aF40C"
    // const flapAddress = "0x95Fb13b7ffd5F55F2D78c26700E16a262aC2EeF8"
    // const flopAddress = "0xf9b7Bbfc5E2acA9a168a50E1807F7903c2f2dF0D"
    // const vowAddress = "0xC913B2Aad7F11404E4E91E53f2388f760F5A3AfA"
    // const potAddress = "0x07964F526825fcdCd54DdEd9aeE063bbb6968517"
    const esdJoinAddress = "0x42FfAe0648A84c0AC72D012402f380ab511AcBb1"
    const spotAddress = "0x92B7e50CE799e8E26dE7324b3a92e93Dbbdf554F"
    const dogAddress = "0x4011fC8085497b72f0287CBB0BcDa853ea07263b"
    const abacusAddress = "0x4529d97aEfAF713E5bB20635f3C6b4Ac48175fC2"

    const gemSymbol = "WEDU"
    let ilk = ethers.encodeBytes32String(gemSymbol);
    // abacus, clip, dog

    // // 필수패키지
    // // 1차 : vat, gem, gemjoin, esd, esdjoin, cdpManager
    // const gemSymbol = "WEDU"

    // // 1) Deploy Vat
    // const vatPath = "src/vat.sol:Vat";
    // const vatArgs = [];
    // const vatAddress = deployAndVerify(vatPath, vatArgs, "");

    // // 2) Deploy Gem : Mainnet 때는 내가 만든걸로 해야함.
    // const gemAddress = "0x345E902846aC3805719483d80D664ABa0B6aF40C";

    // // // 3) Deploy GemJoin
    // const gemJoinPath = "src/join.sol:GemJoin";
    // let ilk = ethers.encodeBytes32String(gemSymbol);
    // const gemJoinArgs = [vatAddress, ilk, gemAddress];
    // const gemJoinAddress = deployAndVerify(gemJoinPath, gemJoinArgs, "address,bytes32,address");

    // // // 4) Deploy Dai
    // const daiPath = "src/ESD.sol:Esd";
    // const daiArgs = [chainId];
    // const daiAddress = deployAndVerify(daiPath, daiArgs, "uint256");

    // // // // 5) Deploy DaiJoin
    // const daiJoinPath = "src/join.sol:DaiJoin";
    // const daiJoinArgs = [vatAddress, daiAddress];
    // const daiJoinAddress = deployAndVerify(daiJoinPath, daiJoinArgs, "address,address");

    // // 6) Deploy CDP Manager
    // const cdpManagerPath = "src/dssCdpManager.sol:DssCdpManager";
    // const cdpManagerArgs = [vatAddress];
    // const cdpManagerAddress = deployAndVerify(cdpManagerPath, cdpManagerArgs, "address");

    // // 7) Deploy Jug
    // const jugContract = "src/jug.sol:Jug";
    // const jugArgs = [vatAddress];
    // const jugAddress = deployAndVerify(jugContract, jugArgs, "address");

    // // 8) Deploy Spot
    // const spotContract = "src/spot.sol:Spotter";
    // const spotArgs = [vatAddress];
    // const spotAddress = deployAndVerify(spotContract, spotArgs, "address");

    // // 9) Deploy flap
    // const flapContract = "src/flap.sol:Flapper";
    // const flapArgs = [vatAddress, gemAddress];
    // const flapAddress = deployAndVerify(flapContract, flapArgs, "address, address");
  
    // // 9) Deploy flop
    // const flopContract = "src/flop.sol:Flopper";
    // const flopArgs = [vatAddress, gemAddress];
    // const flopAddress = deployAndVerify(flopContract, flopArgs, "address, address");

    // // 10) Deploy vow
    // const vowContract = "src/vow.sol:Vow";
    // const vowArgs = [vatAddress, flapAddress, flopAddress];
    // const vowAddress = deployAndVerify(vowContract, vowArgs, "address, address, address");

    // // 10) Deploy pot
    // const potContract = "src/pot.sol:Pot";
    // const potArgs = [vatAddress];
    // const potAddress = deployAndVerify(potContract, potArgs, "address");

    // // 10) Deploy flash   
    // const flashContract = "src/flash.sol:DssFlash";
    // const flashArgs = [esdJoinAddress];
    // const flashAddress = deployAndVerify(flashContract, flashArgs, "address");

    // // 10) Deploy Dog   
    // const dogContract = "src/dog.sol:Dog";
    // const dogArgs = [vatAddress];
    // const dogAddress = deployAndVerify(dogContract, dogArgs, "address");

    // // 10) Deploy clip   
    // const clipContract = "src/clip.sol:Clipper";
    // const clipArgs = [vatAddress, spotAddress,dogAddress, ilk];
    // const clipAddress = deployAndVerify(clipContract, clipArgs, "address,address,address,bytes32");

    // // 10) Deploy abacus   
    // const abacusContract = "src/abaci.sol:LinearDecrease";
    // const abacusArgs = [];
    // const abacusAddress = deployAndVerify(abacusContract, abacusArgs, "");

    // console.log("\nAll contracts deployed and verified successfully!");
    // console.log(`Vat Contract Address: ${vatAddress}`);
    // console.log(`Gem Contract Address: ${gemAddress}`);
    // console.log(`GemJoin Contract Address: ${gemJoinAddress}`);
    // console.log(`XSD Contract Address: ${daiAddress}`);
    // console.log(`XsdJoin Contract Address: ${daiJoinAddress}`);
    // console.log(`CDP Manager Contract Address: ${cdpManagerAddress}`);
    // console.log(`Jug Contract Address: ${jugAddress}`);
    // console.log(`Spot Contract Address: ${spotAddress}`);
    // console.log(`Flap Contract Address: ${flapAddress}`);
    // console.log(`Flop Contract Address: ${flopAddress}`);
    // console.log(`Vow Contract Address: ${vowAddress}`);
    // console.log(`Pot Contract Address: ${potAddress}`);
    // console.log(`flash Contract Address: ${flashAddress}`);
    // console.log(`dog Contract Address: ${dogAddress}`);
    // console.log(`clip Contract Address: ${clipAddress}`);
    // console.log(`abacus Contract Address: ${abacusAddress}`);

};

main();

