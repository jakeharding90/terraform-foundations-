Terraform Foundations

This repository documents the early stages of my transition toward Site Reliability Engineering.

Objective

Build infrastructure exclusively through Infrastructure as Code, with an emphasis on:
	•	Controlled change
	•	Clear lifecycle management
	•	Cost awareness
	•	Reproducibility

Current State

This project provisions an S3 bucket using:
	•	AWS provider
	•	Variables for region and naming
	•	Outputs
	•	Full lifecycle execution: init → plan → apply → destroy

Key Concepts Practised
	•	Provider configuration
	•	Terraform state awareness
	•	Idempotent infrastructure changes
	•	Destructive testing discipline
	•	Git version control hygiene

Next Iterations
	•	Introduce random provider for deterministic uniqueness
	•	Enable bucket versioning
	•	Explore remote state and locking
	•	Modularise configuration
