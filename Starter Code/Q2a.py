from sys import exit
from bitcoin.core.script import *

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                    faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction


######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 2
# Following the instruction, I'd use 2101 as my UNI number to keep the oddness and avoid the negative value for x or y
# x = 11 and y = 10
Q2a_txout_scriptPubKey = [
        # fill this in!
        OP_2DUP,
        OP_ADD,
        21,
        OP_EQUALVERIFY,

        OP_SUB,
        1,
        OP_EQUAL
    ]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.0021 # amount of BTC in the output you're sending minus fee
    txid_to_spend = (
        '4892c910be4cdbd6aed90d0428f8ec27416671dd8927476ab6afe5c378a1a4b5')
    utxo_index = 0 # index of the output you are spending, indices start at 0
    ######################################################################

    response = send_from_P2PKH_transaction(
        amount_to_send, txid_to_spend, utxo_index,
        Q2a_txout_scriptPubKey, my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
