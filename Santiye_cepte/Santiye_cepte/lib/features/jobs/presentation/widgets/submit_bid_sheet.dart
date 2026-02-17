import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/jobs_provider.dart';

/// Teklif Verme Alt Sayfası
class SubmitBidSheet extends StatefulWidget {
  final String jobId;

  const SubmitBidSheet({super.key, required this.jobId});

  @override
  State<SubmitBidSheet> createState() => _SubmitBidSheetState();
}

class _SubmitBidSheetState extends State<SubmitBidSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime? _proposedStartDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _proposedStartDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _proposedStartDate = picked;
      });
    }
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<JobsProvider>();

    // Tutarı parse et (nokta ve virgül temizle)
    final amountText = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(amountText) ?? 0;

    final durationText = _durationController.text;
    final duration = int.tryParse(durationText);

    final success = await provider.submitBid(
      jobId: widget.jobId,
      amount: amount,
      message: _messageController.text.isNotEmpty
          ? _messageController.text
          : null,
      proposedDurationDays: duration,
      proposedStartDate: _proposedStartDate,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teklifiniz başarıyla gönderildi!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (provider.error != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Hata',
              style: TextStyle(color: AppTheme.errorRed),
            ),
            content: Text(provider.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Başlık
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teklif Ver',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Teklifinizi detaylı bir şekilde iletin',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.gray500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Form
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teklif Tutarı
                      _buildLabel('Teklif Tutarı *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          suffixText: '₺',
                          suffixStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Teklif tutarı gerekli';
                          }
                          final amount = int.tryParse(
                            value.replaceAll(RegExp(r'[^\d]'), ''),
                          );
                          if (amount == null || amount < 100) {
                            return 'Minimum teklif tutarı 100 TL';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Önerilen Süre
                      _buildLabel('Tahmini Süre (gün)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Örn: 15',
                          prefixIcon: Icon(Icons.schedule_outlined),
                          suffixText: 'gün',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Başlangıç Tarihi
                      _buildLabel('Başlayabileceğiniz Tarih'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.gray300),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppTheme.gray500,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _proposedStartDate != null
                                      ? DateFormat(
                                          'dd MMMM yyyy',
                                          'tr_TR',
                                        ).format(_proposedStartDate!)
                                      : 'Tarih seçin',
                                  style: TextStyle(
                                    color: _proposedStartDate != null
                                        ? AppTheme.gray900
                                        : AppTheme.gray400,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppTheme.gray400,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Mesaj
                      _buildLabel('Mesajınız'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText:
                              'Kendinizi ve deneyimlerinizi tanıtın, '
                              'neden bu iş için uygun olduğunuzu açıklayın...',
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Gönder Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitBid,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded),
                                    SizedBox(width: 8),
                                    Text('Teklifi Gönder'),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Not
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.infoBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.infoBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Teklifiniz iş sahibine iletilecek ve sizinle iletişime geçecekler.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.infoBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.gray700,
      ),
    );
  }
}

/// Para Birimi Formatlayıcı
class _CurrencyInputFormatter extends TextInputFormatter {
  final _currencyFormat = NumberFormat.decimalPattern('tr_TR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final numericValue = int.tryParse(
      newValue.text.replaceAll(RegExp(r'[^\d]'), ''),
    );
    if (numericValue == null) return oldValue;

    final formatted = _currencyFormat.format(numericValue);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
