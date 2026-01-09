

# Finding 1: Anyone Can Set and Update the Contract Password

## Impact

Any address can set or update the contract password.  
If the password is used to gate owner-only functionality or control funds, an attacker can take full control of the contract by simply setting or updating the password before the legitimate owner does.

## Root Cause

The `setPassword` function is missing an `onlyOwner` (or equivalent) access control check.

```solidity
function setPassword(string memory newPassword) external {
    s_password = newPassword;
    emit SetNewPassword();
}


## Proof of Concept

A non-owner address is able to set the password, and the owner later observes that the password has been overwritten.

```solidity
function testAnyOneCanSetPassword(address randomAddress) public {
    vm.assume(randomAddress != owner);

    vm.prank(randomAddress);
    string memory randomPassword = "myPassWord";
    passwordStore.setPassword(randomPassword);

    vm.prank(owner);
    string memory actualPassword = passwordStore.getPassword();
    assertEq(actualPassword, randomPassword);
}
```

## Recommended Mitigation

Restrict access to the `setPassword` function by enforcing an owner check.

### Updated Function (With Access Control)

```solidity
function setPassword(string memory newPassword) external {
    require(msg.sender == s_owner, "Not owner");
    s_password = newPassword;
    emit SetNewPassword();
}
```



# Finding 2: Anyone Can Read the Password from On-Chain Storage

## Summary

Any user can read the stored password directly from contract storage, even if the variable is marked as `private`.

## Impact

* Storing sensitive data (such as passwords) on-chain is insecure.
* The `private` keyword only restricts access from other contracts, not from users or off-chain tools.
* Anyone can extract the password by reading the contract’s storage slots.

## Root Cause

The password is stored directly on-chain as a state variable:

```solidity
string private s_password;
```

## Proof of Concept

Anyone can inspect the contract’s storage using standard tooling and recover the password.

### Step 1: Read the Storage Slot

```bash
cast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1 \
  --rpc-url http://127.0.0.1:8545
```

This returns the raw storage value:

```text
0x6d7950617373776f726400000000000000000000000000000000000000000014
```

### Step 2: Decode the Stored Value

```bash
cast parse-bytes32-string \
0x6d7950617373776f726400000000000000000000000000000000000000000014
```

The password is revealed in plaintext.

## Recommended Mitigation

* Do not store plaintext secrets on-chain.
* Encrypt the password off-chain before storing it on-chain, or store a cryptographic hash instead.
* Use hashes or signatures for verification rather than plaintext comparison.
```