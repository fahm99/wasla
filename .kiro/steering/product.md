# Wasla - Product Overview

Wasla (وصلة) is an Arabic-first e-learning platform with three distinct user-facing apps sharing a single Supabase backend.

## User Roles

- **Admin**: Manages the platform — approves/suspends accounts, moderates courses, processes payments, sends notifications, and views analytics reports.
- **Provider**: Course creators — build and publish courses with modules, lessons (video/PDF/audio/document), exams, and certificates. Manage student enrollments and submit payment proofs.
- **Student**: Learners — browse and enroll in courses, take exams, earn certificates, and receive notifications.

## Key Domain Concepts

- Courses have modules → lessons (video, PDF, audio, document, image)
- Courses can have exams with multiple question types (multiple choice, true/false, text)
- Payments are manual (bank transfer, e-wallet, cash) and require admin approval
- Certificates are issued upon course completion
- All user accounts go through an approval workflow (PENDING → ACTIVE/REJECTED)
- Account statuses: `PENDING`, `ACTIVE`, `SUSPENDED`, `REJECTED`
- Course statuses: draft/published (provider-side), with admin moderation
- Payment statuses: `PENDING`, `APPROVED`, `REJECTED`

## Language & Locale

The UI is Arabic (ar_SA) with RTL layout. Error messages and UI strings are in Arabic. Code comments are often bilingual (Arabic + English).
