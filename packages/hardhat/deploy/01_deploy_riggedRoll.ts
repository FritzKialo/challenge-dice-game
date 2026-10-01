import { deployScript, artifacts } from "../rocketh/deploy.js";

export default deployScript(
  async env => {
    const diceGame = env.get("DiceGame");
    const diceGameAddress = diceGame.address;

    // Deploy RiggedRoll contract
    const riggedRoll = await env.deploy("RiggedRoll", {
      account: env.namedAccounts.deployer,
      artifact: artifacts.RiggedRoll,
      args: [diceGameAddress],
    });

    // Transfer ownership to the frontend address so it can call withdraw()
    try {
      await env.execute(riggedRoll, {
        functionName: "transferOwnership",
        args: ["0x2b39f858cbd44530CFe1C34984F6242eA2C01c24"],
        account: env.namedAccounts.deployer,
      });
    } catch (err) {
      console.log(err);
    }
  },
  { tags: ["RiggedRoll"] },
);
