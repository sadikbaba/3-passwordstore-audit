# Anyone can set  and update contract password. #

## Impact 
 these can lead to, if there is a fund that only owner can control now the fast finger can control the all contract as he can set password and update it.

 ## Root Cause.
Missing `onlyOwner` check when calling the function.

```javascript 
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNewPassword();
    }

 ```



 ## Proof of concept

``` javascript
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

* By adding require before calling the remaining function this will prevent non_owner from calling the function. require: `require(msg.sender == s_owner); _;`
#

full function after adding require 

```javascript
    function setPassword(string memory newPassword) external {
       require(msg.sender == s_owner); // this is were to add the require
        s_password = newPassword;
        emit SetNewPassword();
    }
```
#


# Another finding

# summary. 
## Any on can read your password offline.

## Impact
* storing private data in blockchain is not recommended .
* even if make variable private its only private to another contract not human.

## Root cause
* Making storing password as variable ` string private s_password;` is the the root cause.

## Proof of concept

* any one can call this to see the password. and will print out the slot where the password is stored.

```
sadikbaba@fedora 3-passwordstore-audit $ cast storage 0x5FbDB2315678afecb367f032d93F
642f64180aa3 1  --rpc-url http://127.0.0.1:8545 
```

* password slot storage `0x6d7950617373776f726400000000000000000000000000000000000000000014` then call this and convert it to origin

```
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```
* password will print out.

#

## Recommended Mitigation:

 * this contract need two encryption, first owner encrypt his password off chain then store it onchain this will make owner to remember his password that stored off chain to decrypt the password onchain.








