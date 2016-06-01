module ApplicationHelper
  # Data for teammates section on landing page.
  def teammates
    [
      ['Travis Johnson', 'Senior Developer', 'assets/face.jpg'],
      ['Justin Joseph', 'Junior Developer', 'assets/face.jpg'],
      ['Jaime Moreno', 'Junior Developer', 'assets/face.jpg'],
      ['Sandra Harrasser', 'Junior Developer', 'assets/face.jpg'],
      ['Sebastian Bedout', 'Junior Developer', 'assets/face.jpg'],
      ['Martin Loekito', 'Junior Developer', 'assets/face.jpg']
    ]
  end

  # Shows the player's email without "@example.com"
  def sign_in_id
    current_player.email[/[^@]+/]
  end
end
