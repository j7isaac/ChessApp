module ApplicationHelper

  private

  # Data for teammates section on landing page.
  def teammates
    [
      ['Travis Johnson', 'Senior Developer', 'assets/team_photos/travis.jpg'],
      ['Justin Joseph', 'Junior Developer', 'assets/team_photos/justin.jpg'],
      ['Jaime Moreno', 'Junior Developer', 'assets/team_photos/jaime.jpg'],
      ['Sandra Harrasser', 'Junior Developer', 'assets/team_photos/sandra.jpg'],
      ['Sebastian Bedout', 'Junior Developer', 'assets/face.jpg'],
      ['Martin Loekito', 'Junior Developer', 'assets/team_photos/martin.jpg']
    ]
  end

  # Shows the player's email without "@example.com"
  def sign_in_id
    current_player.email[/[^@]+/]
  end
end
