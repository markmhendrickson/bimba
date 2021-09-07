
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that <...>",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        return;
        let deployerWallet = accounts.get('deployer')!;
        let block = chain.mineBlock([
            Tx.contractCall(
                `${deployerWallet.address}.coin`,
                'submit-artwork',
                [],
                deployerWallet.address
            )
        ]);
        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result, '(ok u5)');
        assertEquals(block.height, 2);
    },
});
