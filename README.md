BKPasscodeView
==============
- iOS7 style passcode view - supports set password, change password and authenticate password.
- customizable lock policy for too many failure attempts.
- You can customize appearance of passcode digits.


## Screenshots

![Screenshot](./Screenshots/passcode_01.png)
![Screenshot](./Screenshots/passcode_02.png)
![Screenshot](./Screenshots/passcode_03.png)
![Screenshot](./Screenshots/passcode_04.png)
![Screenshot](./Screenshots/passcode_05.png)


## Classes
| Class | Description |
| ----- | ----------- |
| ```BKPasscodeField``` | A custom control that conforms ```UIKeyInput```. When it become first responder keyboard will be displayed to input passcode. |
| ```BKPasscodeInputView``` | A view that supports numeric or normal(ASCII) passcode. This view can display title, message and error message. You can customize label appearances by overriding static methods. |
| ```BKShiftingPasscodeInputView``` | A view that make a transition between two ```BKPasscodeInputView```. You can shift passcode views forward and backward. |
| ```BKPasscodeViewController``` | A view controller that supports create, change and authenticate passcode. |
| ```BKPasscodeLockScreenManager``` | A manager that shows lock screen when application entered background state. You can activate with ```activateWithDelegate:``` method. |


## Example
```obj-c
BKPasscodeViewController *viewController = [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
viewController.delegate = self;
viewController.type = BKPasscodeViewControllerNewPasscodeType;
// viewController.type = BKPasscodeViewControllerChangePasscodeType;    // for change
// viewController.type = BKPasscodeViewControllerCheckPasscodeType;   // for authentication

viewController.passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
// viewController.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle;    // for ASCII style passcode.

UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
[self presentViewController:navController animated:YES completion:nil];

```
