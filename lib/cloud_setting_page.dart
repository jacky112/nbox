import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';


class CloudSettingPage extends StatefulWidget {
    const CloudSettingPage({ Key key }) : super(key: key);
    
    @override
    _CloudSettingPageState createState() => _CloudSettingPageState();
}

class _CloudSettingPageState extends State<CloudSettingPage> {
    
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    
    PersonData person = PersonData();
    
    void showInSnackBar(String value) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(value)
        ));
    }
    
    bool _autovalidate = false;
    bool _formWasEdited = false;
    
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final GlobalKey<FormFieldState<String>> _passwordFieldKey = GlobalKey<FormFieldState<String>>();
    final _UsNumberTextInputFormatter _phoneNumberFormatter = _UsNumberTextInputFormatter();
    
    void _handleSubmitted() {
        final FormState form = _formKey.currentState;
        if (!form.validate()) {
            _autovalidate = true; // Start validating on every change.
            showInSnackBar('Please fix the errors in red before submitting.');
        }
        else {
            form.save();
            showInSnackBar('${person.name}\'s phone number is ${person.phoneNumber}');
        }
    }
    
    String _validateName(String value) {
        _formWasEdited = true;
        if (value.isEmpty)
            return 'Name is required.';
        final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
        if (!nameExp.hasMatch(value))
            return 'Please enter only alphabetical characters.';
        return null;
    }
    
    String _validatePhoneNumber(String value) {
        _formWasEdited = true;
        final RegExp phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
        if (!phoneExp.hasMatch(value))
            return '(###) ###-#### - Enter a US phone number.';
        return null;
    }
    
    String _validatePassword(String value) {
        _formWasEdited = true;
        final FormFieldState<String> passwordField = _passwordFieldKey.currentState;
        if (passwordField.value == null || passwordField.value.isEmpty)
            return 'Please enter a password.';
        if (passwordField.value != value)
            return 'The passwords don\'t match';
        return null;
    }
    
    Future<bool> _warnUserAboutInvalidData() async {
        final FormState form = _formKey.currentState;
        if (form == null || !_formWasEdited || form.validate())
            return true;
        
        return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text('This form has errors'),
                    content: const Text('Really leave this form?'),
                    actions: <Widget> [
                        FlatButton(
                            child: const Text('YES'),
                            onPressed: () { Navigator.of(context).pop(true); },
                        ),
                        FlatButton(
                            child: const Text('NO'),
                            onPressed: () { Navigator.of(context).pop(false); },
                        ),
                    ],
                );
            },
        ) ?? false;
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
                title: const Text('云端设置'),
            ),
            body: SafeArea(
                top: false,
                bottom: false,
                child: Form(
                    key: _formKey,
                    autovalidate: _autovalidate,
                    onWillPop: _warnUserAboutInvalidData,
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    validator: _validateName,
                                    onSaved: (String value) { person.name = value; },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Name *',
                                        //prefixText: '\$',
                                        //suffixText: 'USD',
                                        suffixStyle: TextStyle(color: Colors.green),
                                        hintText: 'What do people call you?',
                                    ),
                                    maxLines: 1,
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'AccessKey ID',
                                        //prefixText: '\$',
                                        //suffixText: 'USD',
                                        suffixStyle: TextStyle(color: Colors.green)
                                    ),
                                    maxLines: 1,
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Access Key Secret',
                                        //prefixText: '\$',
                                        //suffixText: 'USD',
                                        suffixStyle: TextStyle(color: Colors.green)
                                    ),
                                    maxLines: 3,
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Domain',
                                        suffixStyle: TextStyle(color: Colors.green)
                                    ),
                                    maxLines: 2,
                                ),
                                const SizedBox(height: 24.0),
                                PasswordField(
                                    fieldKey: _passwordFieldKey,
                                    helperText: 'No more than 8 characters.',
                                    labelText: 'Password *',
                                    onFieldSubmitted: (String value) {
                                        setState(() {
                                            person.password = value;
                                        });
                                    },
                                ),
                                const SizedBox(height: 24.0),
                                TextFormField(
                                    enabled: person.password != null && person.password.isNotEmpty,
                                    decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        filled: true,
                                        labelText: 'Re-type password',
                                    ),
                                    maxLength: 8,
                                    obscureText: true,
                                    validator: _validatePassword,
                                ),
                                const SizedBox(height: 24.0),
                                Center(
                                    child: RaisedButton(
                                        child: const Text('SUBMIT'),
                                        onPressed: _handleSubmitted,
                                    ),
                                ),
                                const SizedBox(height: 24.0),
                                Text('* indicates required field',style: Theme.of(context).textTheme.caption ),
                                const SizedBox(height: 24.0),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

class PersonData {
    String name = '';
    String phoneNumber = '';
    String email = '';
    String password = '';
}

class PasswordField extends StatefulWidget {
    const PasswordField({
        this.fieldKey,
        this.hintText,
        this.labelText,
        this.helperText,
        this.onSaved,
        this.validator,
        this.onFieldSubmitted,
    });
    
    final Key fieldKey;
    final String hintText;
    final String labelText;
    final String helperText;
    final FormFieldSetter<String> onSaved;
    final FormFieldValidator<String> validator;
    final ValueChanged<String> onFieldSubmitted;
    
    @override
    _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
    bool _obscureText = true;
    
    @override
    Widget build(BuildContext context) {
        return TextFormField(
            key: widget.fieldKey,
            obscureText: _obscureText,
            maxLength: 8,
            onSaved: widget.onSaved,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                hintText: widget.hintText,
                labelText: widget.labelText,
                helperText: widget.helperText,
                suffixIcon: GestureDetector(
                    onTap: () {
                        setState(() {
                            _obscureText = !_obscureText;
                        });
                    },
                    child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        semanticLabel: _obscureText ? 'show password' : 'hide password',
                    ),
                ),
            ),
        );
    }
}



/// Format incoming numeric text to fit the format of (###) ###-#### ##...
class _UsNumberTextInputFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue,
        TextEditingValue newValue
        ) {
        final int newTextLength = newValue.text.length;
        int selectionIndex = newValue.selection.end;
        int usedSubstringIndex = 0;
        final StringBuffer newText = StringBuffer();
        if (newTextLength >= 1) {
            newText.write('(');
            if (newValue.selection.end >= 1)
                selectionIndex++;
        }
        if (newTextLength >= 4) {
            newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ') ');
            if (newValue.selection.end >= 3)
                selectionIndex += 2;
        }
        if (newTextLength >= 7) {
            newText.write(newValue.text.substring(3, usedSubstringIndex = 6) + '-');
            if (newValue.selection.end >= 6)
                selectionIndex++;
        }
        if (newTextLength >= 11) {
            newText.write(newValue.text.substring(6, usedSubstringIndex = 10) + ' ');
            if (newValue.selection.end >= 10)
                selectionIndex++;
        }
        // Dump the rest.
        if (newTextLength >= usedSubstringIndex)
            newText.write(newValue.text.substring(usedSubstringIndex));
        return TextEditingValue(
            text: newText.toString(),
            selection: TextSelection.collapsed(offset: selectionIndex),
        );
    }
}
