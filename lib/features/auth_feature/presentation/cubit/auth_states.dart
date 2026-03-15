abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class AuthLoginLoadingState extends AuthStates {}

class AuthLoginSuccessState extends AuthStates {
  final String uId;
  AuthLoginSuccessState(this.uId);
}

class AuthLoginErrorState extends AuthStates {
  final String error;
  AuthLoginErrorState(this.error);
}

class AuthRegisterLoadingState extends AuthStates {}

class AuthRegisterSuccessState extends AuthStates {
  final String uId;
  AuthRegisterSuccessState(this.uId);
}

class AuthRegisterErrorState extends AuthStates {
  final String error;
  AuthRegisterErrorState(this.error);
}

class AuthCreateUserSuccessState extends AuthStates {
  final String uId;
  AuthCreateUserSuccessState(this.uId);
}

class AuthCreateUserErrorState extends AuthStates {
  final String error;
  AuthCreateUserErrorState(this.error);
}

class AuthSocialLoginSuccessState extends AuthStates {
  final String uId;
  AuthSocialLoginSuccessState(this.uId);
}

class AuthSocialLoginErrorState extends AuthStates {
  final String error;
  AuthSocialLoginErrorState(this.error);
}

class AuthChangePasswordVisibilityState extends AuthStates {}
