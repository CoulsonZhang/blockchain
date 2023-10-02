from sys import exit
from bitcoin.core.script import *
from bitcoin.wallet import CBitcoinSecret, P2PKHBitcoinAddress

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                    faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction

# Private key: cU9KKx8HKQEKswAg8LQ6WeRxhBQnqDze8yD55D84H8aqSnajuQQf
# Address: mobsgdSkTVFbT8xhc18x9WgS1F1KnVJDSa
cust1_private_key = CBitcoinSecret(
    'cU9KKx8HKQEKswAg8LQ6WeRxhBQnqDze8yD55D84H8aqSnajuQQf')
cust1_public_key = cust1_private_key.pub

# Private key: cUCP1eSE8Zby11KTAF8HJsRZ2wk57uQZtfVzLiaeTWowv2eNQSNV
# Address: mqsD4tsr7UNVphB9czNHXX1CukTrYaAz1q
cust2_private_key = CBitcoinSecret(
    'cUCP1eSE8Zby11KTAF8HJsRZ2wk57uQZtfVzLiaeTWowv2eNQSNV')
cust2_public_key = cust2_private_key.pub

# Private key: cNXvCuoGXGYXjGHHaSQeWTPzXuBw3MJgHSa8vuFhjjKs6VdmPvey
# Address: mrj2Bd48w5Ase2mfGQfbmCdDW9LYPmxxgY
cust3_private_key = CBitcoinSecret(
    'cNXvCuoGXGYXjGHHaSQeWTPzXuBw3MJgHSa8vuFhjjKs6VdmPvey')
cust3_public_key = cust3_private_key.pub


######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 3

# You can assume the role of the bank for the purposes of this problem
# and use my_public_key and my_private_key in lieu of bank_public_key and
# bank_private_key.
address = P2PKHBitcoinAddress.from_pubkey(my_private_key.pub)
Q3a_txout_scriptPubKey = [
        # fill this in!
        my_public_key,
        OP_CHECKSIGVERIFY,

        OP_1,
        cust1_public_key,
        cust2_public_key,
        cust3_public_key,
        OP_3,
        OP_CHECKMULTISIG

]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.0011 # amount of BTC in the output you're sending minus fee
    txid_to_spend = (
        'fddd79fcd7c1e9ecc4b1cda79243ffe7e526740a914ab0a3215e2d65122f40eb')
    utxo_index = 9 # index of the output you are spending, indices start at 0
    ######################################################################

    response = send_from_P2PKH_transaction(amount_to_send, txid_to_spend, 
        utxo_index, Q3a_txout_scriptPubKey, my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
