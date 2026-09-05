# RaceDay - API Endpoint Plan

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Registers a new user as either an Organiser or a Participant. | None (public) | `{ fullName, email, password, phoneNumber, role }` | 201 Created - user record created; 400 Bad Request - invalid/missing fields; 409 Conflict - email already registered |
| POST | /api/auth/login | Authenticates a user and returns an access token. | None (public) | `{ email, password }` | 200 OK - token + user info; 401 Unauthorized - invalid credentials |
| GET | /api/users/me | Retrieves the logged-in user's own profile. | Any (logged in) | None | 200 OK - user profile; 401 Unauthorized - not logged in |
| PUT | /api/users/me | Updates the logged-in user's own profile details. | Any (logged in) | `{ fullName, phoneNumber }` | 200 OK - updated profile; 400 Bad Request - invalid fields |
| GET | /api/events | Lists all upcoming events, optionally filtered by type or date. | None (public) | None | 200 OK - array of events |
| GET | /api/events/{id} | Retrieves full details of a single event, including its categories. | None (public) | None | 200 OK - event details; 404 Not Found - event does not exist |
| POST | /api/events | Creates a new event. | Organiser | `{ eventName, eventType, eventDate, location, latitude, longitude, description }` | 201 Created - new event; 400 Bad Request - invalid fields |
| PUT | /api/events/{id} | Updates an event owned by the logged-in organiser. | Organiser | `{ eventName, eventType, eventDate, location, latitude, longitude, description }` | 200 OK - updated event; 403 Forbidden - not the owning organiser; 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event owned by the logged-in organiser. | Organiser | None | 204 No Content; 403 Forbidden - not the owning organiser; 404 Not Found |
| GET | /api/events/{id}/weather | Fetches a live weather forecast for the event's location and date from an external weather API, so participants can prepare for race day. | None (public) | None | 200 OK - forecast (temperature, wind, rain chance); 404 Not Found - event does not exist; 502 Bad Gateway - weather provider unavailable |
| GET | /api/events/{id}/categories | Lists all categories belonging to a specific event. | None (public) | None | 200 OK - array of categories; 404 Not Found - event does not exist |
| POST | /api/events/{id}/categories | Adds a new category to an event. | Organiser | `{ categoryName, distanceKM, minAge, entryFee }` | 201 Created - new category; 403 Forbidden; 404 Not Found |
| PUT | /api/categories/{id} | Updates an existing category. | Organiser | `{ categoryName, distanceKM, minAge, entryFee }` | 200 OK - updated category; 403 Forbidden; 404 Not Found |
| DELETE | /api/categories/{id} | Deletes a category from an event. | Organiser | None | 204 No Content; 403 Forbidden; 404 Not Found |
| GET | /api/categories/{id}/route | Retrieves the route details (start/end point, elevation, map link) for a category, so participants can preview the course. | None (public) | None | 200 OK - route details; 404 Not Found - no route set for this category |
| POST | /api/categories/{id}/route | Creates or replaces the route info for a category. | Organiser | `{ routeName, startPoint, endPoint, elevationGainM, mapUrl, routeNotes }` | 201 Created - route saved; 403 Forbidden; 404 Not Found - category does not exist |
| POST | /api/categories/{id}/enrol | Enrols the logged-in participant into a category and generates a bib number. | Participant | `{ }` (participant identified from login token) | 201 Created - enrolment record with bib number; 404 Not Found - category does not exist; 409 Conflict - already enrolled |
| GET | /api/users/me/enrolments | Lists all events/categories the logged-in participant is currently enrolled in. | Participant | None | 200 OK - array of enrolments |
| DELETE | /api/enrolments/{id} | Cancels an enrolment belonging to the logged-in participant. | Participant | None | 204 No Content; 403 Forbidden - not the owning participant; 404 Not Found |
| GET | /api/users/me/history | Retrieves the logged-in participant's personal performance history - every past event, category, finish time, and position. | Participant | None | 200 OK - array of past results ordered by event date |
| GET | /api/categories/{id}/results | Retrieves the results/leaderboard for a specific category. | None (public) | None | 200 OK - array of results ordered by position; 404 Not Found - category does not exist |
| POST | /api/enrolments/{id}/results | Captures or updates the finish time and position for an enrolment. | Organiser | `{ finishTime, position, status }` | 200 OK - saved result; 403 Forbidden - not the owning organiser; 404 Not Found |
