import 'dart:async';
import 'package:flutter/material.dart';

typedef SearchCallBack = void Function(String userInput);
Widget searchBar(
    TextEditingController searchController, SearchCallBack searchHandler) {
  Timer? debounce;

  void debounceSearchHandler(String searchInput) {
    if (debounce != null) {
      debounce!.cancel();
    }

    debounce = Timer(const Duration(milliseconds: 500), () {
      searchHandler(searchInput);
    });
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
    child: TextField(
      controller: searchController,
      onChanged: (searchInput) {
        debounceSearchHandler(searchInput);
      },
      decoration: const InputDecoration(
        labelText: 'Search Notes',
        border: OutlineInputBorder(),
      ),
    ),
  );
}
