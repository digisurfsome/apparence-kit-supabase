///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsRatePopupEn rate_popup = TranslationsRatePopupEn.internal(_root);
	late final TranslationsPremiumEn premium = TranslationsPremiumEn.internal(_root);
	late final TranslationsActivePremiumEn activePremium = TranslationsActivePremiumEn.internal(_root);
	late final TranslationsPaywallWithSwitchEn paywallWithSwitch = TranslationsPaywallWithSwitchEn.internal(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn.internal(_root);
	late final TranslationsFeatureRequestsEn feature_requests = TranslationsFeatureRequestsEn.internal(_root);
	late final TranslationsUpdateBottomSheetEn update_bottom_sheet = TranslationsUpdateBottomSheetEn.internal(_root);
	late final TranslationsRequestNotificationPermissionEn request_notification_permission = TranslationsRequestNotificationPermissionEn.internal(_root);
	late final TranslationsNotificationPermissionDeniedEn notification_permission_denied = TranslationsNotificationPermissionDeniedEn.internal(_root);
	late final TranslationsReviewPopupEn review_popup = TranslationsReviewPopupEn.internal(_root);
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'ApparenceKit example'
	String get title => 'ApparenceKit example';
}

// Path: rate_popup
class TranslationsRatePopupEn {
	TranslationsRatePopupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Would you have 15s to rate us?'
	String get title => 'Would you have 15s to rate us?';

	/// en: 'It's fast and very helpful! Thanks a lot!'
	String get description => 'It\'s fast and very helpful! Thanks a lot!';

	/// en: 'Maybe later'
	String get cancel_button => 'Maybe later';

	/// en: 'Yes, with pleasure!'
	String get rate_button => 'Yes, with pleasure!';
}

// Path: premium
class TranslationsPremiumEn {
	TranslationsPremiumEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unlock full access'
	String get title_1 => 'Unlock full access';

	/// en: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
	String get description => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

	/// en: 'Feature 1 lorem ipsum '
	String get feature_1 => 'Feature 1 lorem ipsum ';

	/// en: 'Feature 2 mop issum '
	String get feature_2 => 'Feature 2 mop issum ';

	/// en: 'Feature 3 lorem '
	String get feature_3 => 'Feature 3 lorem ';

	/// en: 'Weak'
	String get duration_weekly => 'Weak';

	/// en: 'Year'
	String get duration_annual => 'Year';

	/// en: 'Month'
	String get duration_monthly => 'Month';

	/// en: 'Cancel anytime'
	String get duration_monthly_description => 'Cancel anytime';

	/// en: 'Lifetime'
	String get duration_lifetime => 'Lifetime';

	/// en: 'One time payment'
	String get duration_lifetime_description => 'One time payment';

	/// en: 'Restore'
	String get restore_action => 'Restore';

	/// en: 'Have a coupon?'
	String get coupon_title => 'Have a coupon?';

	/// en: 'Easy 1-click cancel, always'
	String get payment_cancel_reassurance => 'Easy 1-click cancel, always';

	/// en: 'No payment now, cancel anytime'
	String get payment_cancel_reassurance_free_trial => 'No payment now, cancel anytime';

	/// en: 'Start free trial'
	String get payment_action => 'Start free trial';

	/// en: '7-day free trial, then $money'
	String payment_action_trial({required Object money}) => '7-day free trial, then ${money}';

	/// en: 'Try free for $days days'
	String try_free_btn_action({required Object days}) => 'Try free for ${days} days';

	/// en: 'Annual'
	String get duration_recuring_label_annual => 'Annual';

	/// en: 'Monthly'
	String get duration_recuring_label_monthly => 'Monthly';

	/// en: 'Weekly'
	String get duration_recuring_label_weekly => 'Weekly';

	/// en: 'Continue'
	String get action_button => 'Continue';

	/// en: 'Terms'
	String get terms => 'Terms';

	/// en: 'Privacy'
	String get privacy => 'Privacy';

	late final TranslationsPremiumComparisonEn comparison = TranslationsPremiumComparisonEn.internal(_root);
}

// Path: activePremium
class TranslationsActivePremiumEn {
	TranslationsActivePremiumEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You are a premium user'
	String get title => 'You are a premium user';

	/// en: 'Enjoy all the features'
	String get description => 'Enjoy all the features';

	/// en: 'Unsubscribe'
	String get unsubscribe_button => 'Unsubscribe';

	/// en: 'You used a coupon that provided you access to the premium features for free without any subscription. Enjoy!'
	String get early_bird_description => 'You used a coupon that provided you access to the premium features for free without any subscription. Enjoy!';

	/// en: 'Help us improve'
	String get unsubscribe_feedback_title => 'Help us improve';

	/// en: 'We're sorry to see you go. Could you briefly tell us why you're unsubscribing?'
	String get unsubscribe_feedback_description => 'We\'re sorry to see you go. Could you briefly tell us why you\'re unsubscribing?';

	/// en: 'Tell us your reason...'
	String get unsubscribe_feedback_hint => 'Tell us your reason...';

	/// en: 'Minimum 6 characters required'
	String get unsubscribe_feedback_min_chars => 'Minimum 6 characters required';

	/// en: 'You are a lifetime user'
	String get lifetime_user_description => 'You are a lifetime user';

	/// en: 'Cancel'
	String get cancel_button => 'Cancel';
}

// Path: paywallWithSwitch
class TranslationsPaywallWithSwitchEn {
	TranslationsPaywallWithSwitchEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsPaywallWithSwitchWithTrialEn withTrial = TranslationsPaywallWithSwitchWithTrialEn.internal(_root);
	late final TranslationsPaywallWithSwitchNoTrialEn noTrial = TranslationsPaywallWithSwitchNoTrialEn.internal(_root);
	List<String> get features => [
		'Lorem feature 1',
		'Lorem feature 2',
		'Lorem feature 3',
		'Cancel anytime',
	];
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOnboardingFeature1En feature_1 = TranslationsOnboardingFeature1En.internal(_root);
	late final TranslationsOnboardingFeature2En feature_2 = TranslationsOnboardingFeature2En.internal(_root);
	late final TranslationsOnboardingFeature3En feature_3 = TranslationsOnboardingFeature3En.internal(_root);
	late final TranslationsOnboardingAgeQuestionEn ageQuestion = TranslationsOnboardingAgeQuestionEn.internal(_root);
	late final TranslationsOnboardingGenderQuestionEn genderQuestion = TranslationsOnboardingGenderQuestionEn.internal(_root);
	late final TranslationsOnboardingNotificationsEn notifications = TranslationsOnboardingNotificationsEn.internal(_root);
	late final TranslationsOnboardingAttEn att = TranslationsOnboardingAttEn.internal(_root);
	late final TranslationsOnboardingLoadingEn loading = TranslationsOnboardingLoadingEn.internal(_root);
}

// Path: feature_requests
class TranslationsFeatureRequestsEn {
	TranslationsFeatureRequestsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your opinion matters!'
	String get title => 'Your opinion matters!';

	/// en: 'Vote or suggest new features. We listen everyone of you to create the best possible app.'
	String get description => 'Vote or suggest new features.\nWe listen everyone of you to create the best possible app.';

	late final TranslationsFeatureRequestsVoteSuccessEn vote_success = TranslationsFeatureRequestsVoteSuccessEn.internal(_root);
	late final TranslationsFeatureRequestsVoteErrorEn vote_error = TranslationsFeatureRequestsVoteErrorEn.internal(_root);
	late final TranslationsFeatureRequestsAddFeatureEn add_feature = TranslationsFeatureRequestsAddFeatureEn.internal(_root);
}

// Path: update_bottom_sheet
class TranslationsUpdateBottomSheetEn {
	TranslationsUpdateBottomSheetEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What's new?'
	String get title => 'What\'s new?';

	/// en: 'We made some improvements'
	String get description => 'We made some improvements';

	List<String> get highlights => [
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
	];

	/// en: 'Continue'
	String get continue_button => 'Continue';
}

// Path: request_notification_permission
class TranslationsRequestNotificationPermissionEn {
	TranslationsRequestNotificationPermissionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Allow notifications'
	String get title => 'Allow notifications';

	/// en: 'Allow notifications permission to get the best experience'
	String get description => 'Allow notifications permission to get the best experience';

	/// en: 'Allow notifications'
	String get continue_button => 'Allow notifications';

	/// en: 'Maybe later'
	String get skip_button => 'Maybe later';
}

// Path: notification_permission_denied
class TranslationsNotificationPermissionDeniedEn {
	TranslationsNotificationPermissionDeniedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Permission Required'
	String get title => 'Permission Required';

	/// en: 'To receive notifications, please enable notification permissions in your device settings.'
	String get description => 'To receive notifications, please enable notification permissions in your device settings.';

	/// en: 'Allow notifications'
	String get allow_button => 'Allow notifications';

	/// en: 'Open Settings'
	String get open_settings_button => 'Open Settings';

	/// en: 'Cancel'
	String get cancel_button => 'Cancel';
}

// Path: review_popup
class TranslationsReviewPopupEn {
	TranslationsReviewPopupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your opinion matters!'
	String get title => 'Your opinion matters!';

	/// en: 'Help us grow by sharing your experience with others. It only takes a few seconds and makes a huge difference to us 🙏🏻'
	String get description => 'Help us grow by sharing your experience with others. It only takes a few seconds and makes a huge difference to us 🙏🏻';

	/// en: 'Suggest improvements'
	String get cancel_button => 'Suggest improvements';

	/// en: 'Write a review'
	String get rate_button => 'Write a review';
}

// Path: premium.comparison
class TranslationsPremiumComparisonEn {
	TranslationsPremiumComparisonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Premium plan comparison'
	String get title => 'Premium plan comparison';

	/// en: 'Features'
	String get features_label => 'Features';

	/// en: 'Free'
	String get free_version => 'Free';

	/// en: 'Premium'
	String get premium_version => 'Premium';

	/// en: 'No ads'
	String get no_ads => 'No ads';

	/// en: 'Premium themes'
	String get premium_themes => 'Premium themes';

	/// en: 'Advanced customization'
	String get advanced_customization => 'Advanced customization';

	/// en: 'Priority support'
	String get priority_support => 'Priority support';

	/// en: 'Home widgets'
	String get home_widget => 'Home widgets';

	/// en: 'AI Assistant'
	String get talk_with_assistant => 'AI Assistant';
}

// Path: paywallWithSwitch.withTrial
class TranslationsPaywallWithSwitchWithTrialEn {
	TranslationsPaywallWithSwitchWithTrialEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Try Free for $days days'
	String title({required Object days}) => 'Try Free for ${days} days';

	/// en: 'Try for free'
	String get btnAction => 'Try for free';

	/// en: '$days days free, then $price'
	String details({required Object days, required Object price}) => '${days} days free, then ${price}';

	/// en: '$days-day free trial'
	String trial_switch_title({required Object days}) => '${days}-day free trial';
}

// Path: paywallWithSwitch.noTrial
class TranslationsPaywallWithSwitchNoTrialEn {
	TranslationsPaywallWithSwitchNoTrialEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enjoy Your Premium Experience'
	String get title => 'Enjoy Your Premium Experience';

	/// en: 'Continue'
	String get btnAction => 'Continue';

	/// en: 'Not sure yet?'
	String get trial_switch_title => 'Not sure yet?';

	/// en: 'Enable free trial'
	String get trial_switch_subtitle => 'Enable free trial';
}

// Path: onboarding.feature_1
class TranslationsOnboardingFeature1En {
	TranslationsOnboardingFeature1En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Subscriptions module'
	String get title => 'Subscriptions module';

	/// en: 'Manage subscriptions with premade paywalls'
	String get description => 'Manage subscriptions with premade paywalls';

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.feature_2
class TranslationsOnboardingFeature2En {
	TranslationsOnboardingFeature2En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Authentication module'
	String get title => 'Authentication module';

	/// en: 'Manage authentication with premade screens for (login, register, forgot password, etc.)'
	String get description => 'Manage authentication with premade screens for (login, register, forgot password, etc.)';

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.feature_3
class TranslationsOnboardingFeature3En {
	TranslationsOnboardingFeature3En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications module'
	String get title => 'Notifications module';

	/// en: 'Receive push notifications, show in-app notifications, manage permissions, notifications list with status...'
	String get description => 'Receive push notifications, show in-app notifications, manage permissions, notifications list with status...';

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.ageQuestion
class TranslationsOnboardingAgeQuestionEn {
	TranslationsOnboardingAgeQuestionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What is your age?'
	String get title => 'What is your age?';

	/// en: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
	String get description => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

	Map<String, String> get options => {
		'age18_30': '[18 - 30] years old',
		'age31_40': '[31 - 40] years old',
		'age41_50': '[41 - 50] years old',
		'age51_60': '50 years and above',
		'none': 'I prefer not to answer',
	};

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.genderQuestion
class TranslationsOnboardingGenderQuestionEn {
	TranslationsOnboardingGenderQuestionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What is your gender?'
	String get title => 'What is your gender?';

	/// en: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
	String get description => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

	Map<String, String> get options => {
		'male': 'Male',
		'female': 'Female',
		'none': 'I prefer not to answer',
	};

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.notifications
class TranslationsOnboardingNotificationsEn {
	TranslationsOnboardingNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Allow notifications'
	String get title => 'Allow notifications';

	/// en: 'We will only send you important notifications'
	String get description => 'We will only send you important notifications';

	/// en: 'Allow notifications'
	String get continue_button => 'Allow notifications';

	/// en: 'Maybe later'
	String get skip_button => 'Maybe later';
}

// Path: onboarding.att
class TranslationsOnboardingAttEn {
	TranslationsOnboardingAttEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App Tracking Transparency'
	String get title => 'App Tracking Transparency';

	/// en: 'We need this only to improve our ad campaigns'
	String get description => 'We need this only to improve our ad campaigns';

	/// en: 'Continue'
	String get continue_button => 'Continue';
}

// Path: onboarding.loading
class TranslationsOnboardingLoadingEn {
	TranslationsOnboardingLoadingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Creating your profile'
	String get title => 'Creating your profile';

	/// en: 'Wait a few seconds'
	String get subtitle => 'Wait a few seconds';
}

// Path: feature_requests.vote_success
class TranslationsFeatureRequestsVoteSuccessEn {
	TranslationsFeatureRequestsVoteSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Thank you!'
	String get title => 'Thank you!';

	/// en: 'Your vote has been taken into account'
	String get description => 'Your vote has been taken into account';
}

// Path: feature_requests.vote_error
class TranslationsFeatureRequestsVoteErrorEn {
	TranslationsFeatureRequestsVoteErrorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error'
	String get title => 'Error';

	/// en: 'You already voted for a feature'
	String get description => 'You already voted for a feature';
}

// Path: feature_requests.add_feature
class TranslationsFeatureRequestsAddFeatureEn {
	TranslationsFeatureRequestsAddFeatureEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Suggest a feature'
	String get title => 'Suggest a feature';

	/// en: 'What feature would you like to see in the app?'
	String get description => 'What feature would you like to see in the app?';

	/// en: 'Send'
	String get save_button => 'Send';

	/// en: 'Feature title'
	String get title_label => 'Feature title';

	/// en: 'Enter a short descriptive title'
	String get title_hint => 'Enter a short descriptive title';

	/// en: 'Description'
	String get description_label => 'Description';

	/// en: 'Describe the feature or the improvement you would like to see in the app'
	String get description_hint => 'Describe the feature or the improvement you would like to see in the app';

	late final TranslationsFeatureRequestsAddFeatureToastSuccessEn toast_success = TranslationsFeatureRequestsAddFeatureToastSuccessEn.internal(_root);
}

// Path: feature_requests.add_feature.toast_success
class TranslationsFeatureRequestsAddFeatureToastSuccessEn {
	TranslationsFeatureRequestsAddFeatureToastSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Thank you!'
	String get title => 'Thank you!';

	/// en: 'We will review your suggestion'
	String get description => 'We will review your suggestion';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'home.title' => 'ApparenceKit example',
			'rate_popup.title' => 'Would you have 15s to rate us?',
			'rate_popup.description' => 'It\'s fast and very helpful! Thanks a lot!',
			'rate_popup.cancel_button' => 'Maybe later',
			'rate_popup.rate_button' => 'Yes, with pleasure!',
			'premium.title_1' => 'Unlock full access',
			'premium.description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'premium.feature_1' => 'Feature 1 lorem ipsum ',
			'premium.feature_2' => 'Feature 2 mop issum ',
			'premium.feature_3' => 'Feature 3 lorem ',
			'premium.duration_weekly' => 'Weak',
			'premium.duration_annual' => 'Year',
			'premium.duration_monthly' => 'Month',
			'premium.duration_monthly_description' => 'Cancel anytime',
			'premium.duration_lifetime' => 'Lifetime',
			'premium.duration_lifetime_description' => 'One time payment',
			'premium.restore_action' => 'Restore',
			'premium.coupon_title' => 'Have a coupon?',
			'premium.payment_cancel_reassurance' => 'Easy 1-click cancel, always',
			'premium.payment_cancel_reassurance_free_trial' => 'No payment now, cancel anytime',
			'premium.payment_action' => 'Start free trial',
			'premium.payment_action_trial' => ({required Object money}) => '7-day free trial, then ${money}',
			'premium.try_free_btn_action' => ({required Object days}) => 'Try free for ${days} days',
			'premium.duration_recuring_label_annual' => 'Annual',
			'premium.duration_recuring_label_monthly' => 'Monthly',
			'premium.duration_recuring_label_weekly' => 'Weekly',
			'premium.action_button' => 'Continue',
			'premium.terms' => 'Terms',
			'premium.privacy' => 'Privacy',
			'premium.comparison.title' => 'Premium plan comparison',
			'premium.comparison.features_label' => 'Features',
			'premium.comparison.free_version' => 'Free',
			'premium.comparison.premium_version' => 'Premium',
			'premium.comparison.no_ads' => 'No ads',
			'premium.comparison.premium_themes' => 'Premium themes',
			'premium.comparison.advanced_customization' => 'Advanced customization',
			'premium.comparison.priority_support' => 'Priority support',
			'premium.comparison.home_widget' => 'Home widgets',
			'premium.comparison.talk_with_assistant' => 'AI Assistant',
			'activePremium.title' => 'You are a premium user',
			'activePremium.description' => 'Enjoy all the features',
			'activePremium.unsubscribe_button' => 'Unsubscribe',
			'activePremium.early_bird_description' => 'You used a coupon that provided you access to the premium features for free without any subscription. Enjoy!',
			'activePremium.unsubscribe_feedback_title' => 'Help us improve',
			'activePremium.unsubscribe_feedback_description' => 'We\'re sorry to see you go. Could you briefly tell us why you\'re unsubscribing?',
			'activePremium.unsubscribe_feedback_hint' => 'Tell us your reason...',
			'activePremium.unsubscribe_feedback_min_chars' => 'Minimum 6 characters required',
			'activePremium.lifetime_user_description' => 'You are a lifetime user',
			'activePremium.cancel_button' => 'Cancel',
			'paywallWithSwitch.withTrial.title' => ({required Object days}) => 'Try Free for ${days} days',
			'paywallWithSwitch.withTrial.btnAction' => 'Try for free',
			'paywallWithSwitch.withTrial.details' => ({required Object days, required Object price}) => '${days} days free, then ${price}',
			'paywallWithSwitch.withTrial.trial_switch_title' => ({required Object days}) => '${days}-day free trial',
			'paywallWithSwitch.noTrial.title' => 'Enjoy Your Premium Experience',
			'paywallWithSwitch.noTrial.btnAction' => 'Continue',
			'paywallWithSwitch.noTrial.trial_switch_title' => 'Not sure yet?',
			'paywallWithSwitch.noTrial.trial_switch_subtitle' => 'Enable free trial',
			'paywallWithSwitch.features.0' => 'Lorem feature 1',
			'paywallWithSwitch.features.1' => 'Lorem feature 2',
			'paywallWithSwitch.features.2' => 'Lorem feature 3',
			'paywallWithSwitch.features.3' => 'Cancel anytime',
			'onboarding.feature_1.title' => 'Subscriptions module',
			'onboarding.feature_1.description' => 'Manage subscriptions with premade paywalls',
			'onboarding.feature_1.action' => 'Continue',
			'onboarding.feature_2.title' => 'Authentication module',
			'onboarding.feature_2.description' => 'Manage authentication with premade screens for (login, register, forgot password, etc.)',
			'onboarding.feature_2.action' => 'Continue',
			'onboarding.feature_3.title' => 'Notifications module',
			'onboarding.feature_3.description' => 'Receive push notifications, show in-app notifications, manage permissions, notifications list with status...',
			'onboarding.feature_3.action' => 'Continue',
			'onboarding.ageQuestion.title' => 'What is your age?',
			'onboarding.ageQuestion.description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'onboarding.ageQuestion.options.age18_30' => '[18 - 30] years old',
			'onboarding.ageQuestion.options.age31_40' => '[31 - 40] years old',
			'onboarding.ageQuestion.options.age41_50' => '[41 - 50] years old',
			'onboarding.ageQuestion.options.age51_60' => '50 years and above',
			'onboarding.ageQuestion.options.none' => 'I prefer not to answer',
			'onboarding.ageQuestion.action' => 'Continue',
			'onboarding.genderQuestion.title' => 'What is your gender?',
			'onboarding.genderQuestion.description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'onboarding.genderQuestion.options.male' => 'Male',
			'onboarding.genderQuestion.options.female' => 'Female',
			'onboarding.genderQuestion.options.none' => 'I prefer not to answer',
			'onboarding.genderQuestion.action' => 'Continue',
			'onboarding.notifications.title' => 'Allow notifications',
			'onboarding.notifications.description' => 'We will only send you important notifications',
			'onboarding.notifications.continue_button' => 'Allow notifications',
			'onboarding.notifications.skip_button' => 'Maybe later',
			'onboarding.att.title' => 'App Tracking Transparency',
			'onboarding.att.description' => 'We need this only to improve our ad campaigns',
			'onboarding.att.continue_button' => 'Continue',
			'onboarding.loading.title' => 'Creating your profile',
			'onboarding.loading.subtitle' => 'Wait a few seconds',
			'feature_requests.title' => 'Your opinion matters!',
			'feature_requests.description' => 'Vote or suggest new features.\nWe listen everyone of you to create the best possible app.',
			'feature_requests.vote_success.title' => 'Thank you!',
			'feature_requests.vote_success.description' => 'Your vote has been taken into account',
			'feature_requests.vote_error.title' => 'Error',
			'feature_requests.vote_error.description' => 'You already voted for a feature',
			'feature_requests.add_feature.title' => 'Suggest a feature',
			'feature_requests.add_feature.description' => 'What feature would you like to see in the app?',
			'feature_requests.add_feature.save_button' => 'Send',
			'feature_requests.add_feature.title_label' => 'Feature title',
			'feature_requests.add_feature.title_hint' => 'Enter a short descriptive title',
			'feature_requests.add_feature.description_label' => 'Description',
			'feature_requests.add_feature.description_hint' => 'Describe the feature or the improvement you would like to see in the app',
			'feature_requests.add_feature.toast_success.title' => 'Thank you!',
			'feature_requests.add_feature.toast_success.description' => 'We will review your suggestion',
			'update_bottom_sheet.title' => 'What\'s new?',
			'update_bottom_sheet.description' => 'We made some improvements',
			'update_bottom_sheet.highlights.0' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.1' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.2' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.continue_button' => 'Continue',
			'request_notification_permission.title' => 'Allow notifications',
			'request_notification_permission.description' => 'Allow notifications permission to get the best experience',
			'request_notification_permission.continue_button' => 'Allow notifications',
			'request_notification_permission.skip_button' => 'Maybe later',
			'notification_permission_denied.title' => 'Permission Required',
			'notification_permission_denied.description' => 'To receive notifications, please enable notification permissions in your device settings.',
			'notification_permission_denied.allow_button' => 'Allow notifications',
			'notification_permission_denied.open_settings_button' => 'Open Settings',
			'notification_permission_denied.cancel_button' => 'Cancel',
			'review_popup.title' => 'Your opinion matters!',
			'review_popup.description' => 'Help us grow by sharing your experience with others. It only takes a few seconds and makes a huge difference to us 🙏🏻',
			'review_popup.cancel_button' => 'Suggest improvements',
			'review_popup.rate_button' => 'Write a review',
			_ => null,
		};
	}
}
