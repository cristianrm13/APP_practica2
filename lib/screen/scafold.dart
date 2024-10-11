import 'package:flutter/material.dart';

class GladBoxHomeScreen extends StatelessWidget {
  const GladBoxHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GladBox',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'comunidad',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.add_circle_outline, size: 28),
                SizedBox(width: 15),
                Icon(Icons.notifications_none, size: 28),
                SizedBox(width: 15),
                Icon(Icons.settings, size: 28),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '¿Qué está pasando?',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const PostCard(
              title: 'Sin energia electrica',
              date: '30/09/2024',
              description: 'Desde hace ya 3 dias en el barrio San Jacinto no tenemos energia electrica',
              votes: 10,
            ),
             const PostCard(
              title: 'Título 2',
              date: '01/10/2024',
              description: 'Descripción, Descripción, Descripción, Descripción, Descripción, '
                  'Descripción, Descripción, Descripción, Descripción, Descripción',
              votes: 10,
            ),
            const PostCard(
              title: 'Título 3',
              date: '02/10/2024',
              description: 'Descripción, Descripción, Descripción, Descripción, Descripción, '
                  'Descripción, Descripción, Descripción, Descripción, Descripción',
              votes: 5,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.orange[200],
        height: 50,
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final int votes;

  const PostCard({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up, size: 20),
                        const SizedBox(width: 5),
                        Text('$votes votos'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
