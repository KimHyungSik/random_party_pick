import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/gradient_button.dart';

class JoinRoomForm extends StatefulWidget {
  final TextEditingController inviteCodeController;
  final Function(String) onJoinRoom;
  final bool isLoading;
  final GlobalKey<FormState> formKey;

  const JoinRoomForm({
    super.key,
    required this.inviteCodeController,
    required this.onJoinRoom,
    required this.isLoading,
    required this.formKey,
  });

  @override
  State<JoinRoomForm> createState() => _JoinRoomFormState();
}

class _JoinRoomFormState extends State<JoinRoomForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: widget.inviteCodeController,
                decoration: InputDecoration(
                  labelText: l10n.roomCode,
                  hintText: l10n.enterRoomCode,
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9]'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.enterRoomCode;
                  }
                  if (value.trim().length != 6) {
                    return '6 characters required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: widget.isLoading
                      ? null
                      : () => widget.onJoinRoom(widget.inviteCodeController.text
                          .trim()
                          .toUpperCase()),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.join,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}