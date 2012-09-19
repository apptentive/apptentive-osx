2012-09-19 wooster v0.4.7
-------------------------
The big change here is a switch to git subtrees from a submodule for the copy of apptentive-ios in the project. This makes checking out the project and getting started much easier.

Changes:

* Fix for ratings dialog not showing up due to reachability failing.
* OSX-6 Switch to git subtrees for apptentive-ios

2012-08-29 wooster v0.4.6
-------------------------
Changes:

* Pulled in v0.4.5 of apptentive-ios.
* Went from JSONKit to PrefixedJSONKit.
* Removed methods for displaying different feedback window types on OS X.
* Added placeholder text in feedback window.
