Feature: Fargate service

  Background: I have a Fargate service
    Given I have aws_ecs_service defined
    When its launch_type is FARGATE

  Scenario: Fargate service doesn't have public IP
    Then it must contain network_configuration
    And it must contain assign_public_ip
    And its value must be false

  Scenario: Fargate service must be isolated with a security group
    Then it must contain network_configuration
    Then it must have security_groups
    And its value must not be null

