import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';
import 'package:fluttershare/models/user.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController myController = TextEditingController();
  Future<QuerySnapshot> users;

  handleSearch(String query) {
    Future<QuerySnapshot> searchResults = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      users = searchResults;
    });
  }

  AppBar buildSearchHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: myController,
        decoration: InputDecoration(
            hintText: "Search for a user ...",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                myController.clear();
              },
            )),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  NoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Expanded(
            flex: 5,
            child: SvgPicture.asset(
              "assets/images/search.svg",
              height: orientation == Orientation.portrait ? 300 : 200,
              alignment: Alignment.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Find Users",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 60),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: users,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress(context);
          }
          List<UserResult> searchResultList = [];
          snapshot.data.documents.forEach((doc) {
            User user_doc = User.fromDocument(doc);
            UserResult userResult = UserResult(user: user_doc);
            searchResultList.add(userResult);
          });
          if (searchResultList.length == 0) {
            return NoContent();
          } else {
            return ListView(
              children: searchResultList,
            );
          }
        });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchHeader(),
      body: users == null ? NoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  User user;
  UserResult({this.user});

  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profile(profileId: user.id))),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                backgroundColor: Colors.grey,
              ),
            ),
            title: Text(
              user.displayName,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              user.username,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Divider(
            color: Colors.white54,
            height: 2,
          )
        ],
      ),
    );
  }
}
