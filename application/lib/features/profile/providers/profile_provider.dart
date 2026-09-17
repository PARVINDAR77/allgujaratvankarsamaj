import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile_model.dart';


class ProfileNotifier extends StateNotifier<List<ProfileModel>> {
  ProfileNotifier() : super(_initialData);

  static final List<ProfileModel> _initialData = [
    const ProfileModel(
      id: '1',
      firstName: 'Dipak',
      lastName: 'Vankar',
      gender: 'Male (પુરુષ)',
      maritalStatus: 'Never Married (અપરિણીત)',
      dateOfBirth: '1990-01-01',
      employmentType: 'Government Sector (સરકારી નોકરી / સેકટર)',
      department: 'IAS',
      designation: 'IAS Officer',
      district: 'Gandhinagar',
      taluka: 'Gandhinagar',
      pargana: '24 Pargana / Chovisey (ચોવીસી)',
    ),
    const ProfileModel(
      id: '2',
      firstName: 'Riddhi',
      lastName: 'Vankar',
      gender: 'Female (સ્ત્રી)',
      maritalStatus: 'Never Married (અપરિણીત)',
      dateOfBirth: '1992-05-12',
      employmentType: 'Government Sector (સરકારી નોકરી / સેકટર)',
      department: 'Education',
      designation: 'Teacher',
      district: 'Ahmedabad',
      taluka: 'Ahmedabad City',
      pargana: '7 Pargana (૭ પરગણા)',
    ),
    const ProfileModel(
      id: '3',
      firstName: 'Hardik',
      lastName: 'Vankar',
      gender: 'Male (પુરુષ)',
      maritalStatus: 'Never Married (અપરિણીત)',
      dateOfBirth: '1988-11-20',
      employmentType: 'Government Sector (સરકારી નોકરી / સેકટર)',
      department: 'Police',
      designation: 'Police Inspector',
      district: 'Surat',
      taluka: 'Choryasi',
      pargana: '22 Pargana (૨૨ પરગણા)',
    ),
    const ProfileModel(
      id: '4',
      firstName: 'Rahul',
      lastName: 'Vankar',
      gender: 'Male (પુરુષ)',
      maritalStatus: 'Never Married (અપરિણીત)',
      dateOfBirth: '1995-08-15',
      employmentType: 'Private Sector (ખાનગી નોકરી / સેકટર)',
      department: 'IT',
      designation: 'Software Engineer',
      district: 'Ahmedabad',
      taluka: 'Ahmedabad City',
      pargana: '42 Pargana (૪૨ પરગણા)',
    ),
  ];

  void addProfile(ProfileModel profile) {
    state = [profile, ...state];
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, List<ProfileModel>>((ref) {
  return ProfileNotifier();
});
