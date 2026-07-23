import '../models/about_content.dart';
import '../repositories/about_repository.dart';

class AboutViewModel {
  AboutViewModel({AboutRepository? repository})
    : _repository = repository ?? const AboutRepository();

  final AboutRepository _repository;

  String get heroBadge => AboutRepository.heroBadge;
  String get heroTitle => AboutRepository.heroTitle;
  String get heroDescription => AboutRepository.heroDescription;

  List<AboutFeature> get features => _repository.getFeatures();
  List<AboutBenefit> get benefits => _repository.getBenefits();
  List<AboutProcessStep> get processSteps => _repository.getProcessSteps();
}
