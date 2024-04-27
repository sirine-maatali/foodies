class UnboardingContent {
  late String image;
  late String title;
  late String description;
  UnboardingContent(
      {required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents = [
  UnboardingContent(
      description: 'pick your food free our menu\n  More than 35 times',
      image: "images/screen1.png",
      title: 'Select from Our\n  Best Menu'),
  UnboardingContent(
      description:
          'you can pay cash on delivery and\n  card payement is available',
      image: "images/screen2.png",
      title: "Easy and Online payment"),
  UnboardingContent(
      description: 'Deliver your food at your\n  Doorstep',
      image: "images/screen3.png",
      title: 'Quick Delivery at Your Doorstep')
];
