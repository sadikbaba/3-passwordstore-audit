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


# Another fining




