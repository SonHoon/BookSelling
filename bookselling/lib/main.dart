import 'package:riverpod/riverpod.dart';
import 'dart:io';

// Define the model class
class Book {
  String name;
  double price;
  int quantity;

  Book({required this.name, required this.price, required this.quantity});
}

class Sale {
  String bookName;
  int quantity;
  double total;

  Sale({required this.bookName, required this.quantity, required this.total});
}

// Define providers for state management
final bookListProvider = StateProvider<List<Book>>((ref) => []);
final salesProvider = StateProvider<List<Sale>>((ref) => []);

void main() {
  final container = ProviderContainer();
  final bookList = container.read(bookListProvider.notifier);
  final salesList = container.read(salesProvider.notifier);

  print('Welcome to HDM Book Store');

  while (true) {
    print('\nChoices:');
    print('[1] - Add Book');
    print('[2] - View Books');
    print('[3] - Buy Book');
    print('[4] - View Sales');
    print('[5] - Exit');

    stdout.write('Enter choice: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        _addBook(bookList);
        break;
      case '2':
        _viewBooks(container);
        break;
      case '3':
        _buyBook(bookList, salesList);
        break;
      case '4':
        _viewSales(container);
        break;
      case '5':
        container.dispose();
        exit(0);
      default:
        print('Invalid choice, please try again.');
    }
  }
}

void _addBook(StateController<List<Book>> bookList) {
  stdout.write('Enter book name: ');
  final name = stdin.readLineSync()!;
  stdout.write('Enter book price: ');
  final price = double.parse(stdin.readLineSync()!);
  stdout.write('Enter book quantity: ');
  final quantity = int.parse(stdin.readLineSync()!);

  bookList.update((state) =>
      [...state, Book(name: name, price: price, quantity: quantity)]);
}

void _viewBooks(ProviderContainer container) {
  final books = container.read(bookListProvider);
  print('Books available:');
  for (var book in books) {
    print('${book.name} - Price: \$${book.price}, Quantity: ${book.quantity}');
  }
}

void _buyBook(StateController<List<Book>> bookList,
    StateController<List<Sale>> salesList) {
  stdout.write('Enter book name to buy: ');
  final name = stdin.readLineSync()!;
  stdout.write('Enter quantity to buy: ');
  final quantity = int.parse(stdin.readLineSync()!);

  final books = bookList.state;
  final bookIndex = books.indexWhere((book) => book.name == name);

  if (bookIndex != -1) {
    final book = books[bookIndex];
    if (book.quantity >= quantity) {
      final total = book.price * quantity;
      bookList.update((state) {
        final updatedBooks = List<Book>.from(state);
        updatedBooks[bookIndex] = Book(
          name: book.name,
          price: book.price,
          quantity: book.quantity - quantity,
        );
        return updatedBooks;
      });

      salesList.update((state) => [
            ...state,
            Sale(bookName: book.name, quantity: quantity, total: total)
          ]);
      print('Purchase successful! Total: \$${total}');
    } else {
      print('Not enough stock available.');
    }
  } else {
    print('Book not found.');
  }
}

void _viewSales(ProviderContainer container) {
  final sales = container.read(salesProvider);
  print('Sales records:');
  for (var sale in sales) {
    print(
        'Book: ${sale.bookName}, Quantity: ${sale.quantity}, Total: \$${sale.total}');
  }
}
