# &#10003;polls
## a Basejump for freeCodeCamp
This is a MeteorJS version for a practice assignment for freeCodeCamp. You can try it at [polls-janmp.meteor.com](http://polls-janmp.meteor.com).
The (official) Angular Full Stack version can be found [here](https://github.com/JanMP/vote).

###Todo - now
+   get a username for users that are logged in with twitter: with validation working now, users logged in with twitter can't save polls, because they don't have the required username
+   validation: server side validation is working, but there's nothing communicated to the user if validation fails (this silent refusal to update the db feels like it's buggy)
+   the pie charts keep firing loads of error messages in the console, figure out if I have to take care of destroying the chart objects

###Todo - some day
+   an admin role, so I don't have to use the mongo shell to delete crappy test-polls from lazy users that just enter random letters 
+   comments and social buttons
+   tweak the layout
+   get fancy with css