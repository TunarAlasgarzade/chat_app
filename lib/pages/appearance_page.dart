import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Appearance"),
          ),
          body: Column(
            children: [
              // dark mode
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                margin: const EdgeInsets.only(right: 15, left: 15, top: 15),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dark Mode"),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 7),
              
              // primary color
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                margin: const EdgeInsets.only(right: 15, left: 15, top: 15),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Accent Color"),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.green),
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 20,
                            child: themeProvider.color == Colors.green
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.red),
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 20,
                            child: themeProvider.color == Colors.red
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.cyan),
                          child: CircleAvatar(
                            backgroundColor: Colors.cyan,
                            radius: 20,
                            child: themeProvider.color == Colors.cyan
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.blue),
                          child: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 20,
                            child: themeProvider.color == Colors.blue
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.teal),
                          child: CircleAvatar(
                            backgroundColor: Colors.teal,
                            radius: 20,
                            child: themeProvider.color == Colors.teal
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.purple),
                          child: CircleAvatar(
                            backgroundColor: Colors.purple,
                            radius: 20,
                            child: themeProvider.color == Colors.purple
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () => context.read<ThemeProvider>().changeColor(Colors.pinkAccent),
                          child: CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                            radius: 20,
                            child: themeProvider.color == Colors.pinkAccent
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}