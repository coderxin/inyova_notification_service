# README

Implementation of Take-home assignment from Inyova (Inyova_SOFTWARE_ENGINEER_assignment_level_3.pdf).

## Requirements

### Implement a notification center

Inyova would like to implement a new project - the backend for a new notification center. Admins should be able
to set up these notifications and clients should be able to get the latest notifications relevant for them.

### Implementation and deliverable
- Ruby on Rails project
- PostgreSQL database
- You can use any gems if you consider them needed
- The result will be a link to a private git repository

### Features
You will develop a REST API for both admins and clients.
- As an **admin** I can:
  - Create a notification with a date, title and description
  - Assign a notification to one or multiple clients
  - Know if a notification has been seen by a client
- As a **client** I can:
  - View my notifications

Additionally, whenever a notification is created, it needs to be delivered through our mock push notification
gem.

Please keep the API response time under 200ms regardless of the volume.

## Assumptions

Assumptions that were made by me based on the given requirements:

- `date` attribute of the `Notification` entity does imply
    - the time after which notification is becoming visible to assigned client
    - the day when push notifications has to be dispatched to the client
    - push notifications are scheduled in advance (or for the current or past date)
- push notifications are sent to individual client devices (based on `some_unique_device_token` (https://www.rubydoc.info/gems/mock_push_service/0.1.0))

## Setup

This implementation does require:
- Ruby `3.2.2`
- Postgres `14.8`
- Redis `ruby-3.2.2`

I have used RVM, therefore:

```bash
rvm install ruby-3.2.2
rvm use ruby-3.2.2@notification_service --create
gem install bundler:2.4
bundle install
```

Setup of the database:
```bash
rake db:create db:migrate db:seed
```

Rspec Specs: 
```bash
bundle exec rspec 
```

Linter:
```bash
bundle exec rubocop 
```

Running (will run `rails` and `sidekiq`):
```bash
bin/dev
```

## API documentation



For convenience please use [Postman collection](https://github.com/coderxin/inyova_notification_service/blob/main/docs/Notification%20Service%20API.postman_collection.json). 

```
POST   /api/v1/sessions                                                                        
DELETE /api/v1/sessions   
                                                                     
GET    /api/v1/notifications                                                                   
GET    /api/v1/notifications/:id                                                               
PATCH  /api/v1/notifications/:notification_id/reads                                            
    
GET    /api/v1/admin/notifications                                                             
POST   /api/v1/admin/notifications                                                             
GET    /api/v1/admin/notifications/:id                                                         
                                                     
GET    /api/v1/admin/notifications/:notification_id/assignments                               
POST   /api/v1/admin/notifications/:notification_id/assignments
```

## Design choices

- Use `sidekiq` to utilise exponential backoff for third-party integration failures
- Utilise `Jobs` to abstract integration that might occasionally fail or hit with the latency
- Add representation of the `PushNotification` with state machine to allow safe execution multiple times
- Introduced `PATCH /api/v1/notifications/{id}/reads` to guarantee idempotency of the `/api/v1/notifications` and make client to decide when to mark notifications as seen/read

Please also see [PR descriptions](https://github.com/coderxin/inyova_notification_service/pulls?q=is%3Apr+is%3Aclosed).

## Potential further improvements

- configure to be production ready 
- add more specs
- introduce policy objects for authorisation
- configure cors
- add pagination (for example using kaminari) for response time optimisation
- add doker-compose to run Rails, PostgreSQL, Redis and Sidekiq in isolation
- add swagger API documentation (for example using swagger-blocks gem)
- add password protection for sidekiq routes
- use dedicated sidekiq queue for push_notifications or priority to avoid waiting times for other jobs
- gracefully handle jobs that are missing entries in the context (for example notifications has been deleted, etc.)
- add Github actions to run specs, rubocop and deploy to staging and production server
