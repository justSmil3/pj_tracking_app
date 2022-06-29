// Uri retrieveUrl = Uri.file('http://localhost:5000');
// Uri deleteUrl(int idx) { return Uri.file("http://localhost:5000$idx");}

const String ip = "http://134.93.175.117:80";

Uri tasksUrl = Uri.parse("$ip/tasks/");
Uri taskUrl(int idx) {
  return Uri.parse("$ip/tasks/$idx/");
}

Uri subtasksUrl = Uri.parse("$ip/subtasks/");
Uri mentiSubtaskUrl(int idx) {
  return Uri.parse("$ip/subtasks/menti/$idx/");
}

Uri oSubtasksUrl(String name) {
  return Uri.parse("$ip/osubtasks/$name/");
}

Uri SubtaskOrderedByTaskUrl = Uri.parse("$ip/subtasksOrderedByTask/");
Uri subtaskUrl(int idx) {
  return Uri.parse("$ip/subtasks/$idx/");
}

Uri tracksUrl = Uri.parse('$ip/tracks/');
Uri trackByTaskUrl(int idx) {
  return Uri.parse("$ip/tracks/byTask/$idx/");
}

Uri createTrackUrl = Uri.parse('$ip/tracks/create/');
Uri deleteTrackUrl(int idx) {
  return Uri.parse("$ip/tracks/$idx/delete/");
}

Uri updateTrackUrl(int idx) {
  return Uri.parse("$ip/tracks/$idx/update/");
}

Uri trackUrl(int idx) {
  return Uri.parse("$ip/tracks/$idx/");
}

Uri mentiTrackUrl(int idx) {
  return Uri.parse("$ip/mentiTracks/$idx/");
}

Uri weightsUrl = Uri.parse('$ip/weights/');
Uri addWeightsUrl = Uri.parse('$ip/addweightscore/');
Uri CountedWeightsUrl(int count) {
  return Uri.parse("$ip/weights/$count");
}

Uri DeleteWeightsUrl(int idx) {
  return Uri.parse("$ip/weights/$idx/delete/");
}

Uri CountedStatsUrl(int count) {
  return Uri.parse("$ip/stats/$count/");
}

Uri CountedWStatsUrl(int count) {
  return Uri.parse("$ip/weightedUserStats/$count/");
}

Uri CountedUStatsUrl(int count) {
  return Uri.parse("$ip/unweightedUserStats/$count/");
}

Uri CountedUserStatsUrl(int idx, int count) {
  return Uri.parse("$ip/stats/$idx/$count/");
}

Uri CountedWUserStatsUrl(int idx, int count) {
  return Uri.parse("$ip/weightedStats/$idx/$count/");
}

Uri CountedUUserStatsUrl(int idx, int count) {
  return Uri.parse("$ip/unweightedStats/$idx/$count/");
}

Uri mentiUrl = Uri.parse('$ip/menti/');
Uri WeightsOfUserUrl(int user) {
  return Uri.parse('$ip/taskweights/user/$user/');
}

Uri WeightsOfUserByTaskUrl(int user, int task) {
  return Uri.parse('$ip/weights/byTask/$user/$task/');
}

Uri createTaskWeightUrl = Uri.parse('$ip/taskweight/create/');
Uri updateWeightUrl(int idx) {
  return Uri.parse("$ip/weights/$idx/update/");
}

Uri userCheckUrl = Uri.parse('$ip/userStatus/');
// Todo setup all urls (connect them to the endpoints in the backend)

Uri sendMessageUrl = Uri.parse("$ip/messages/add/");
Uri GetMessages(int start, int count) {
  return Uri.parse("$ip/messages/$start/$count/");
}

Uri GetMentiMessages(int mentiId, int start, int count) {
  return Uri.parse("$ip/mentiMessages/$mentiId/$start/$count/");
}

Uri GetUnreadMessagesCount(int mentiID) {
  return Uri.parse("$ip/messages/$mentiID/unread/");
}

Uri getMentorIdUrl = Uri.parse("$ip/mentorid/");
Uri forgotPasswordUrl = Uri.parse("$ip/forgotPassword/");
Uri resetPasswordUrl = Uri.parse("$ip/resetPassword/");
