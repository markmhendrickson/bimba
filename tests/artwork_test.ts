
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that mint and related functions work as expected",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let deployerWallet = accounts.get('deployer')!;
        let recipientWallet = accounts.get('wallet_1')!;
        let block = chain.mineBlock([
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'mint',
                [
                    types.ascii('http://example1.org'), 
                    types.principal(deployerWallet.address)
                ],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'mint',
                [
                    types.ascii('http://example2.org'), 
                    types.principal(deployerWallet.address)
                ],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'mint',
                [
                    types.ascii('http://example3.org'), 
                    types.principal(deployerWallet.address)
                ],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'get-last-token-id',
                [],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'get-token-uri',
                [
                    types.uint(2),
                ],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'get-owner',
                [
                    types.uint(3),
                ],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'transfer',
                [
                    types.uint(3),
                    types.principal(deployerWallet.address),
                    types.principal(recipientWallet.address)
                ],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.artwork`,
                'get-owner',
                [
                    types.uint(3),
                ],
                deployerWallet.address
            )
        ]);

        assertEquals(block.receipts[0].result, '(ok u1)');
        assertEquals(block.receipts[1].result, '(ok u2)');
        assertEquals(block.receipts[2].result, '(ok u3)');
        assertEquals(block.receipts[3].result, '(ok u3)');
        assertEquals(block.receipts[4].result, '(ok (some "http://example2.org"))');
        assertEquals(block.receipts[5].result, `(ok (some ${deployerWallet.address}))`);
        assertEquals(block.receipts[6].result, '(ok true)');
        assertEquals(block.receipts[7].result, `(ok (some ${recipientWallet.address}))`);
    },
});
