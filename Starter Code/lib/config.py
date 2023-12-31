from bitcoin import SelectParams
from bitcoin.base58 import decode
from bitcoin.core import x
from bitcoin.wallet import CBitcoinAddress, CBitcoinSecret, P2PKHBitcoinAddress


SelectParams('testnet')

faucet_address = CBitcoinAddress('mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB')

# For questions 1-3, we are using 'btc-test3' network. For question 4, you will
# set this to be either 'btc-test3' or 'bcy-test'
network_type = 'btc-test3'


######################################################################
# This section is for Questions 1-3
# TODO: Fill this in with your private key.
#
# Create a private key and address pair in Base58 with keygen.py
# Send coins at https://testnet-faucet.mempool.co/

my_private_key = CBitcoinSecret(
    'cQ2NqKDTgCNT65ghFL2C8gE4YBNo2bwTaJBMrMGfywsfuAFqHsnR')

my_public_key = my_private_key.pub
my_address = P2PKHBitcoinAddress.from_pubkey(my_public_key)
######################################################################


######################################################################
# NOTE: This section is for Question 4
# TODO: Fill this in with address secret key for BTC testnet3
#
# Create address in Base58 with keygen.py
# Send coins at https://testnet-faucet.mempool.co/

# Only to be imported by alice.py
# Alice should have coins!!
alice_secret_key_BTC = CBitcoinSecret(
    'cSDr3aX6qfTtnZaJkpXrKXMrsVDKhLxEM9iqFru2PuXVfpQrvqPV')

# Only to be imported by bob.py
bob_secret_key_BTC = CBitcoinSecret(
    'cS73RibmJsYUPKd3aw5Se98z8JyzETWYZytp11vN8yC4EL4ZAcjJ')

# Can be imported by alice.py or bob.py
alice_public_key_BTC = alice_secret_key_BTC.pub
alice_address_BTC = P2PKHBitcoinAddress.from_pubkey(alice_public_key_BTC)

bob_public_key_BTC = bob_secret_key_BTC.pub
bob_address_BTC = P2PKHBitcoinAddress.from_pubkey(bob_public_key_BTC)
######################################################################


######################################################################
# NOTE: This section is for Question 4
# TODO: Fill this in with address secret key for BCY testnet
#
# Create address in hex with
# curl -X POST https://api.blockcypher.com/v1/bcy/test/addrs?token=29e6377afd4642f591db438d2108d8e5
# This request will return a private key, public key and address. Make sure to save these.
#
# Send coins with
# curl -d '{"address": "BvZC9fJ5KaPpdVJxL6WqK7cLf63ED9qg2R", "amount": 1000000}' 'https://api.blockcypher.com/v1/bcy/test/faucet?token=29e6377afd4642f591db438d2108d8e5'
# This request will return a transaction reference. Make sure to save this.

# Only to be imported by alice.py
alice_secret_key_BCY = CBitcoinSecret.from_secret_bytes(
    x('42b3a2bf1919ba82553d6ef642a2f9cce002f120172cba392a896e951872c9b8'))

# Only to be imported by bob.py
# Bob should have coins!!
bob_secret_key_BCY = CBitcoinSecret.from_secret_bytes(
    x('2f547aca674ac798e903710e6e7c240a37cd3cdfcb5fe6deab443c6537c27dc1'))

# Can be imported by alice.py or bob.py
alice_public_key_BCY = alice_secret_key_BCY.pub
alice_address_BCY = P2PKHBitcoinAddress.from_pubkey(alice_public_key_BCY)

bob_public_key_BCY = bob_secret_key_BCY.pub
bob_address_BCY = P2PKHBitcoinAddress.from_pubkey(bob_public_key_BCY)
######################################################################
