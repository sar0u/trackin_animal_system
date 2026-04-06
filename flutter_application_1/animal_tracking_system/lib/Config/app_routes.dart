import 'package:flutter/material.dart';
import '../Presentation/Screens/Animals/add_animal_screen.dart';
import '../Presentation/Screens/Animals/animal_passport_screen.dart';
import '../Presentation/Screens/Animals/animals_list_screen.dart';
import '../Presentation/Screens/Animals/scan_rfid_screen.dart';
import '../Presentation/Screens/Auth/login_screen.dart';
import '../Presentation/Screens/Auth/register_screen.dart';
import '../Presentation/Screens/EidMode/eid_home_screen.dart';
import '../Presentation/Screens/EidMode/verify_animal_screen.dart';
import '../Presentation/Screens/Farms/add_farm_screen.dart';
import '../Presentation/Screens/Farms/farm_detail_screen.dart';
import '../Presentation/Screens/Farms/farms_list_screen.dart';
import '../Presentation/Screens/Health/add_health_record_screen.dart';
import '../Presentation/Screens/Health/health_history_screen.dart';
import '../Presentation/Screens/Home/dashboard_screen.dart';
import '../Presentation/Screens/Home/home_screen.dart';
import '../Presentation/Screens/Map/map_screen.dart';
import '../Presentation/Screens/Profile/change_password_screen.dart';
import '../Presentation/Screens/Profile/edit_profile_screen.dart';
import '../Presentation/Screens/Profile/forgot_password_screen.dart';
import '../Presentation/Screens/Profile/help_support_screen.dart';
import '../Presentation/Screens/Profile/profile_screen.dart';
import '../Presentation/Screens/Profile/settings_screen.dart';
import '../Presentation/Screens/Reports/create_report_screen.dart';
import '../Presentation/Screens/Reports/reports_screen.dart';
import '../Presentation/Screens/Splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String animalsList = '/animals-list';
  static const String addAnimal = '/add-animal';
  static const String animalPassport = '/animal-passport';
  static const String scanRfid = '/scan-rfid';
  static const String farmsList = '/farms-list';
  static const String addFarm = '/add-farm';
  static const String farmDetail = '/farm-detail';
  static const String healthHistory = '/health-history';
  static const String addHealthRecord = '/add-health-record';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String helpSupport = '/help-support';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String createReport = '/create-report';
  static const String eidHome = '/eid-home';
  static const String verifyAnimal = '/verify-animal';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    dashboard: (context) => const DashboardScreen(),
    animalsList: (context) => const AnimalsListScreen(),
    addAnimal: (context) => const AddAnimalScreen(),
    animalPassport: (context) => AnimalPassportScreen(animal: null!), // Hack provisoire ou utiliser MaterialPageRoute
    scanRfid: (context) => const ScanRfidScreen(),
    farmsList: (context) => const FarmsListScreen(),
    addFarm: (context) => const AddFarmScreen(),
    farmDetail: (context) => const FarmDetailScreen(),
    healthHistory: (context) => const HealthHistoryScreen(),
    addHealthRecord: (context) => const AddHealthRecordScreen(),
    map: (context) => const MapScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    helpSupport: (context) => const HelpSupportScreen(),
    settings: (context) => const SettingsScreen(),
    reports: (context) => const ReportsScreen(),
    createReport: (context) => const CreateReportScreen(),
    eidHome: (context) => const EidHomeScreen(),
    verifyAnimal: (context) => const VerifyAnimalScreen(),
  };
}