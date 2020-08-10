#  GithubUsers Test App

## Overview

This app queries the Github API to show an infinite-scrolling list of Github users. Clicking on a Github user shows their profile in a detail view.

## Checklist: Completed Requirements

### Generic Requirements

Required 9, completed 9.

	✅ Code must be done in Swift 5.1. using Xcode 11.x
	✅ CoreData​ must be used for data persisting.
	✅ UI must be done with ​UIKit​ using ​AutoLayout.
	✅ All ​network calls​ must be ​queued​ and limited to 1 request at a time.
	✅ All ​media​ has to be ​cached​ on disk.
	✅ For GitHub api requests, for image loading & caching and for CoreData integration only Apple's apis are allowed (no 3rd party libraries).
	✅ Use Codable to inflate models fetched from api.
	✅ Write Unit tests for data processing logic & models.
	✅ If functional programming approach is used then only ​Combine​ is permitted.

### Github Users

Required 3, completed 3.

	✅ The app has to be able to work offline if data has been previously loaded.
	✅ The app must handle ​no internet ​scenario.
	✅ The app must retry loading data once the connection is available.

### Users List

Required 7, completed 7.

	✅ Github users list can be obtained from ​https://api.github.com/users?since=0​ in JSON format.
	✅ The list must support pagination (​scroll to load more​) utilizing ​since p​ arameter as the integer ID of the last User loaded.
	✅ Page size​ has to be dynamically determined after the first batch is loaded.
	✅ The list has to display a spinner while loading data as the last list item.
	✅ Every fourth avatar's colour should have its colours inverted.
	✅ List item view should have a note icon if there is note information saved for the given user.
	✅ List (table/collection view) must be implemented using at least ​3 different cells (normal, note & inverted) and ​Protocols

### Profile

Required 3, completed 3.

	✅ Profile info can be obtained from ​https://api.github.com/users/[​username​] in JSON format (e.g. ​https://api.github.com/users/tawk​).
	✅ The view should have the user's avatar as a header view followed by information fields (UIX is up to you).
	✅ The section must have the possibility to retrieve and save back the ​Note​ data (not available in GitHub api; local storage only).

### Bonus

Optional 10, completed 5.

	❌ Empty views such as list items (while data is still loading) should have Loading Shimmer aka ​Skeletons​ ~ https://miro.medium.com/max/4000/0*s7uxK77a0FY43NLe.png​ ​resembling​ final views​.
	❌ Exponential backoff ​must be used​ ​when trying to reload the data.
	✅ Any data fetch should utilize ​Result types.​
	❌ CoreData stack implementation must use ​two managed contexts​ - 1.​main context​ to be used for reading data and feeding into UI 2. write (​background) context​ - that is used for writing data.
	✅ All CoreData ​write​ queries must be ​queued​ while allowing one concurrent query at any time.
	✅ Coordinator and/or MVVM patterns are used.
	✅ Users list UI must be done in code and Profile - with Interface Builder.
	❌ Items in users list are greyed out a bit for seen profiles (seen status being saved to db).
	❌ Users list has to be searchable - local search only; in ​search mode,​ there is no pagination; username and note (see Profile section) fields should be used when searching; precise match as well as ​contains s​ hould be used.
	✅ The app has to support ​dark mode​.

## Developer's Notes

### Caching strategy

If there are cached objects, the objects are loaded from Core Data; otherwise, a network call is made and saved to Core Data. The app **does not** check for whether the objects stored in Core Data have gone stale, and the `UserListViewController` remotely fetches then caches the next page of users based on the last user ID in the cached data. Refreshing the data requires an explicit pull-to-refresh from the user list screen.

### Overview of Classes

* The worker functions that fetch from a URL and read/write to Core Data are in classes called "services". There are three types: `HTTPService` for URL requests, `CoreDataService` for Core Data read/writes, and `CombinedService` for services that combine the two (e.g. fetching over the network and then caching in Core Data).

* Services are nested to take advantage of namespacing. The convention is `SERVICE_TYPE.SERVICE_NAME.ACTION`. For example, the service that fetches users from the Github API is called `HTTPService.Users.Fetch`, and the service that saves the results to Core Data is `CoreDataService.Users.Save`.

### Retrying Network Requests

Retrying failed network requests is handled by the `RetryController` class.

### Unit Tests

As the scope of the sample app is already quite exhaustive, I've added in two unit tests inside the class `Test_HTTPService_Users_Fetch`.

1. `test_returnedEmptyArray_requestShouldSucceedWithEmptyArray()` - Tests that a fetch on the Github Users API that returns an empty array counts as a successful fetch. This applies to the case when the user reaches the end of pagination. This unit test actually performs a network call on the Github API.

2. `test_returnedInvalidUsers_requestShouldSucceedButSaveShouldFail()` - Mocks a call to the Github Users API that returns three users, one of which is invalid (`login` property is missing). The network call should count as a success despite the invalid object. The test then proceeds to save in Core Data, which is then expected to fail because the login (`username` in the managed object) is missing. This test **does not** actually make a network call on the Github API--it returns mock data instead.
