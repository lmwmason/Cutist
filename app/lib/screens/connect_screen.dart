import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/coach_controller.dart';
import '../core/device_transport.dart';
import '../theme/toss_tokens.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/toss_button.dart';
import 'dashboard_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    await context.read<CoachController>().refreshDevices();
  }

  Future<void> _connect(TransportDevice device) async {
    final coach = context.read<CoachController>();
    await coach.connect(device);
    if (!mounted || !coach.connected) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CoachController>(
          builder: (context, coach, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      TossSpacing.xl,
                      TossSpacing.lg,
                      TossSpacing.xl,
                      TossSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a device to connect',
                          style: TossTextStyles.body,
                        ),
                        const SizedBox(height: TossSpacing.xl),
                        if (coach.lastError != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(TossSpacing.lg),
                            margin: const EdgeInsets.only(bottom: TossSpacing.lg),
                            decoration: BoxDecoration(
                              color: TossColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(TossRadius.md),
                            ),
                            child: Text(
                              coach.lastError!,
                              style: TossTextStyles.bodySmall.copyWith(color: TossColors.danger),
                            ),
                          ),
                        Expanded(
                          child: coach.connecting
                              ? const Center(child: CircularProgressIndicator())
                              : coach.devices.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No devices found',
                                        style: TossTextStyles.bodySmall,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: coach.devices.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: TossSpacing.md),
                                      itemBuilder: (context, index) {
                                        final device = coach.devices[index];
                                        return _DeviceTile(
                                          device: device,
                                          onTap: () => _connect(device),
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: TossSpacing.lg),
                        TossButton(
                          label: 'Refresh',
                          variant: TossButtonVariant.weak,
                          onPressed: coach.connecting ? null : _refresh,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final TransportDevice device;
  final VoidCallback onTap;

  const _DeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TossColors.surface,
      borderRadius: BorderRadius.circular(TossRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TossRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(TossSpacing.lg),
          child: Row(
            children: [
              Icon(
                device.owner.kind == TransportKind.bluetooth
                    ? Icons.bluetooth
                    : Icons.usb,
                color: TossColors.muted,
                size: 20,
              ),
              const SizedBox(width: TossSpacing.md),
              Expanded(
                child: Text(device.label, style: TossTextStyles.body),
              ),
              const Icon(Icons.chevron_right, color: TossColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
