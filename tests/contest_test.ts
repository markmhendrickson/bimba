
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that submit-artwork and related functions work as expected",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let deployerWallet = accounts.get('deployer')!;
        let wallet1 = accounts.get('wallet_1')!;
        let wallet2 = accounts.get('wallet_2')!;
        let wallet3 = accounts.get('wallet_3')!;

        let block = chain.mineBlock([
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'submit-artwork',
                [
                    types.ascii('http://example1.org/artwork1.json'),
                    types.uint(0)
                ],
                wallet1.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'submit-artwork',
                [
                    types.ascii('http://example1.org/artwork2.json'),
                    types.uint(0)
                ],
                wallet2.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'submit-artwork',
                [
                    types.ascii('http://example1.org/artwork3.json'),
                    types.uint(0)
                ],
                wallet3.address
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
                `${deployerWallet.address}.contest`,
                'submit-vote',
                [
                    types.uint(3),
                    types.uint(0),
                ],
                wallet1.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'submit-vote',
                [
                    types.uint(3),
                    types.uint(10),
                ],
                wallet3.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'submit-vote',
                [
                    types.uint(2),
                    types.uint(20),
                ],
                wallet2.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'submit-artwork',
                [
                    types.ascii('http://example1.org/artwork1.json'),
                    types.uint(1)
                ],
                wallet1.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'get-total-stx-amount',
                [],
                deployerWallet.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'get-vote-data',
                [
                    types.principal(wallet2.address),
                    types.uint(1)
                ],
                wallet3.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'is-vote-winner',
                [
                    types.principal(wallet1.address),
                    types.uint(1)
                ],
                wallet1.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'is-vote-winner',
                [
                    types.principal(wallet2.address),
                    types.uint(1)
                ],
                wallet1.address
            ),
            Tx.contractCall(
                `${deployerWallet.address}.contest`,
                'is-vote-winner',
                [
                    types.principal(wallet3.address),
                    types.uint(1)
                ],
                wallet1.address
            ),
        ]);

        assertEquals(block.receipts[0].result, `(ok {artwork-id: u1, coin-amount: u0, round: u1, submitter: ${wallet1.address}})`);
        assertEquals(block.receipts[1].result, `(ok {artwork-id: u2, coin-amount: u0, round: u1, submitter: ${wallet2.address}})`);
        assertEquals(block.receipts[2].result, `(ok {artwork-id: u3, coin-amount: u0, round: u1, submitter: ${wallet3.address}})`);
        assertEquals(block.receipts[3].result, '(ok (some "http://example1.org/artwork2.json"))');
        assertEquals(block.receipts[4].result, `(ok {artwork-id: u3, round: u1, stx-amount: u0, submitter: ${wallet1.address}})`);
        assertEquals(block.receipts[5].result, `(ok {artwork-id: u3, round: u1, stx-amount: u10, submitter: ${wallet3.address}})`);
        assertEquals(block.receipts[6].result, `(ok {artwork-id: u2, round: u1, stx-amount: u20, submitter: ${wallet2.address}})`);
        assertEquals(block.receipts[7].result, '(err u3)');
        assertEquals(block.receipts[8].result, '(ok u30)');
        assertEquals(block.receipts[9].result, '(ok {artwork-id: (some u2), round-previous-stx-total: (some u10), round-stx-total: (some u30), stx-amount: (some u20)})');
        assertEquals(block.receipts[10].result, '(ok false)');
        assertEquals(block.receipts[11].result, '(ok false)');
        assertEquals(block.receipts[12].result, '(ok true)');
    },
});
