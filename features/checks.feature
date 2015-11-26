@product
Feature: Various checks

  Scenario: AppArmor is enabled and has enforced profiles
    Given I have started Tails from DVD without network and logged in
    Then AppArmor is enabled
    And some AppArmor profiles are enforced

  Scenario: GNOME Screenshot has a sane default save directory
    Given I have started Tails from DVD without network and logged in
    Then GNOME Screenshot is configured to save files to the live user's home directory

  Scenario: GNOME Screenshot takes a screenshot when the PRINTSCREEN key is pressed
    Given I have started Tails from DVD without network and logged in
    And there is no screenshot in the live user's home directory
    When I press the "PRINTSCREEN" key
    Then a screenshot is saved to the live user's home directory

  Scenario: VirtualBox guest modules are available
    Given I have started Tails from DVD without network and logged in
    When Tails has booted a 64-bit kernel
    Then the VirtualBox guest modules are available

  @fragile
  Scenario: The shipped Tails OpenPGP keys are up-to-date
    Given I have started Tails from DVD without network and logged in
    Then the OpenPGP keys shipped with Tails will be valid for the next 3 months

  Scenario: The Tails Debian repository key is up-to-date
    Given I have started Tails from DVD without network and logged in
    Then the shipped Debian repository key will be valid for the next 3 months

  Scenario: The "Report an Error" launcher will open the support documentation
    Given I have started Tails from DVD without network and logged in
    And the network is plugged
    And Tor is ready
    And all notifications have disappeared
    When I double-click the Report an Error launcher on the desktop
    Then the support documentation page opens in Tor Browser

  Scenario: The live user is setup correctly
    Given I have started Tails from DVD without network and logged in
    Then the live user has been setup by live-boot
    And the live user is a member of only its own group and "audio cdrom dialout floppy video plugdev netdev fuse scanner lp lpadmin vboxsf"
    And the live user owns its home dir and it has normal permissions

  Scenario: No initial network
    Given I have started Tails from DVD without network and logged in
    And I wait between 30 and 60 seconds
    When the network is plugged
    And Tor is ready
    And all notifications have disappeared
    And the time has synced
    And process "vidalia" is running within 30 seconds

  Scenario: The 'Tor is ready' notification is shown when Tor has bootstrapped
    Given I have started Tails from DVD without network and logged in
    And the network is plugged
    When I see the 'Tor is ready' notification
    Then Tor is ready

  Scenario: The tor process should be confined with Seccomp
    Given I have started Tails from DVD without network and logged in
    And the network is plugged
    And Tor is ready
    Then the running process "tor" is confined with Seccomp in filter mode

  Scenario: No unexpected network services
    Given I have started Tails from DVD without network and logged in
    When the network is plugged
    And Tor is ready
    Then no unexpected services are listening for network connections

  Scenario: The emergency shutdown applet can shutdown Tails
    Given I have started Tails from DVD without network and logged in
    When I request a shutdown using the emergency shutdown applet
    Then Tails eventually shuts down

  Scenario: The emergency shutdown applet can reboot Tails
    Given I have started Tails from DVD without network and logged in
    When I request a reboot using the emergency shutdown applet
    Then Tails eventually restarts

  Scenario: tails-debugging-info does not leak information
    Given I have started Tails from DVD without network and logged in
    Then tails-debugging-info is not susceptible to symlink attacks

  Scenario: The Tails Greeter "disable all networking" option disables networking within Tails
    Given I have started Tails from DVD without network and stopped at Tails Greeter's login screen
    And I enable more Tails Greeter options
    And I disable all networking in the Tails Greeter
    And I log in to a new session
    And the Tails desktop is ready
    When the network is plugged
    And I wait 120 seconds
    Then no network interfaces are enabled
    And process "NetworkManager" is not running
    And process "tor" is not running
    But process "nm-applet" is running
    And network traffic is not generated during the Tails session

  Scenario: Anti-test: Network traffic is generated when "disable all networking" is not selected
    Given I have started Tails from DVD without network and stopped at Tails Greeter's login screen
    And I log in to a new session
    And the Tails desktop is ready
    When the network is plugged
    Then process "NetworkManager" is running
    And Tor is ready
    Then network traffic is generated during the Tails session
