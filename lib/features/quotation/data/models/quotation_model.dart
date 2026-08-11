import '../../domain/entities/quotation_entities.dart';

class QuotationModel {
  final Quotation value;

  const QuotationModel(this.value);

  Quotation toEntity() => value;

  factory QuotationModel.fromEntity(Quotation quotation) => QuotationModel(quotation);
}
