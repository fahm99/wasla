import '../models/certificate_model.dart';
import '../services/supabase_service.dart';

class CertificateController {
  Future<List<CertificateModel>> getMyCertificates() async {
    return await SupabaseService.getMyCertificates();
  }

  Future<CertificateModel> getCertificateById(String certificateId) async {
    return await SupabaseService.getCertificateById(certificateId);
  }
}
