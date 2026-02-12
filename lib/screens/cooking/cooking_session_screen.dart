import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flavour/models/recipe.dart';

class CookingSessionScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingSessionScreen({super.key, required this.recipe});

  @override
  State<CookingSessionScreen> createState() => _CookingSessionScreenState();
}

class _CookingSessionScreenState extends State<CookingSessionScreen>
    with TickerProviderStateMixin {
  // Page state
  int _currentPage = 0; // 0: Cooking, 1: Complete/Photo

  // Timer state
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool get _allStepsCompleted => _stepCompleted.every((completed) => completed);

  // Animation controllers
  late AnimationController _cookingAnimationController;
  late AnimationController _steamAnimationController;
  late AnimationController _completionController;

  // Animations
  late Animation<double> _potBounce;
  late Animation<double> _steamRise;
  late Animation<double> _lidWobble;

  // Checklist state
  late List<bool> _ingredientChecked;
  late List<bool> _stepCompleted;
  int _currentStep = 0;

  // Photo state
  File? _capturedPhoto;

  @override
  void initState() {
    super.initState();

    // Initialize timer
    _totalSeconds = widget.recipe.cookingTime * 60;
    _remainingSeconds = _totalSeconds;

    // Initialize checklists
    _ingredientChecked = List.filled(widget.recipe.ingredients.length, false);
    _stepCompleted = List.filled(widget.recipe.instructions.length, false);

    // Setup animations
    _setupAnimations();

    // Keep screen awake (add wakelock package for production)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setupAnimations() {
    // Cooking pot animation
    _cookingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _potBounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _cookingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _lidWobble = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _cookingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Steam animation
    _steamAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _steamRise = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _steamAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Completion animation
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
      _totalSeconds += seconds;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
      _currentPage = 1;
    });
    _completionController.forward();
    HapticFeedback.heavyImpact();
  }

  void _finishCooking() {
    _timer?.cancel();
    setState(() {
      _isCompleted = true;
      _currentPage = 1;
    });
    _completionController.forward();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _takePhoto() async {
    // For now, show a placeholder dialog
    // In production, use image_picker package
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('📸 Capture Your Creation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Camera Preview'),
                  SizedBox(height: 4),
                  // Text(
                  //   'Add image_picker package\nfor real camera access',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(fontSize: 12, color: Colors.grey),
                  // ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Simulate photo taken
                _capturedPhoto = File('placeholder');
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo saved! 🎉'),
                  backgroundColor: Color(0xFF2EC4B6),
                ),
              );
            },
            icon: const Icon(Icons.camera),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cookingAnimationController.dispose();
    _steamAnimationController.dispose();
    _completionController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: _currentPage == 0 ? _buildCookingPage() : _buildCompletionPage(),
      ),
    );
  }

  // ==================== COOKING PAGE ====================
  Widget _buildCookingPage() {
    return Column(
      children: [
        // Header
        _buildHeader(),

        // Main content (scrollable)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cooking Animation & Timer
                _buildCookingAnimation(),

                const SizedBox(height: 16),

                // Recipe Details
                SizedBox(
                  height: 300, // Fixed height for tabs
                  child: _buildRecipeDetails(),
                ),
              ],
            ),
          ),
        ),

        // Bottom Controls
        _buildBottomControls(),
      ],
    );
  }
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now Cooking',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  widget.recipe.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${_currentStep + 1}/${widget.recipe.instructions.length}',
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookingAnimation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated cooking pot with steam
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Steam particles
                ...List.generate(3, (index) => _buildSteamParticle(index)),

                // Pot
                AnimatedBuilder(
                  animation: _cookingAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _potBounce.value),
                      child: _buildCookingPot(),
                    );
                  },
                ),
              ],
            ),
          ),
          // Timer display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _totalSeconds > 0
                        ? (_totalSeconds - _remainingSeconds) / _totalSeconds
                        : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                // Timer controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimerButton(
                      icon: Icons.remove,
                      onTap: () => _addTime(-60),
                      label: '-1m',
                    ),
                    const SizedBox(width: 16),
                    _buildPlayPauseButton(),
                    const SizedBox(width: 16),
                    _buildTimerButton(
                      icon: Icons.add,
                      onTap: () => _addTime(60),
                      label: '+1m',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookingPot() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Pot body
        Container(
          width: 100,
          height: 70,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A4A4A), Color(0xFF2D2D2D)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        // Pot rim
        Container(
          width: 110,
          height: 15,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF5A5A5A),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Lid (wobbling)
        AnimatedBuilder(
          animation: _cookingAnimationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _lidWobble.value,
              child: Container(
                width: 90,
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A6A6A), Color(0xFF4A4A4A)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Handles
        Positioned(
          left: -15,
          top: 40,
          child: Container(
            width: 20,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Positioned(
          right: -15,
          top: 40,
          child: Container(
            width: 20,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSteamParticle(int index) {
    return AnimatedBuilder(
      animation: _steamAnimationController,
      builder: (context, child) {
        final delay = index * 0.3;
        final progress = ((_steamRise.value + delay) % 1.0);
        final opacity = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

        return Positioned(
          top: 10 - (progress * 50),  // Reduced height
          left: 30 + (index - 1) * 15.0 + (progress * 8 * (index - 1)),  // Adjusted position
          child: Opacity(
            opacity: opacity.clamp(0.0, 0.6),
            child: Container(
              width: 10 + (progress * 6),  // Smaller steam
              height: 10 + (progress * 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey[600],fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _isRunning ? _pauseTimer : _startTimer,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          _isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: const Color(0xFFFF6B35),
              unselectedLabelColor: Colors.grey[500],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 18),
                      SizedBox(width: 6),
                      Text('Steps'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.egg_alt_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Ingredients'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildStepsTab(),
                _buildIngredientsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: widget.recipe.instructions.length,
      itemBuilder: (context, index) {
        final isCompleted = _stepCompleted[index];
        final isCurrentStep = index == _currentStep;
        final isLocked = index > _currentStep && !isCompleted;

        return GestureDetector(
          onTap: () {
            // Locked steps can't be tapped
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Complete Step ${_currentStep + 1} first'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.grey[700],
                ),
              );
              return;
            }

            setState(() {
              if (isCompleted) {
                // UNDO: Uncheck this step and all steps after it
                _stepCompleted[index] = false;
                // Uncheck all subsequent steps too
                for (int i = index + 1; i < _stepCompleted.length; i++) {
                  _stepCompleted[i] = false;
                }
                // Move current step back to this one
                _currentStep = index;
              } else if (index == _currentStep) {
                // COMPLETE: Mark current step as done
                _stepCompleted[index] = true;
                // Move to next step if not the last one
                if (index < widget.recipe.instructions.length - 1) {
                  _currentStep = index + 1;
                }
                // If it's the last step, _currentStep stays (all done!)
              }
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentStep && !isCompleted
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : isCompleted
                  ? const Color(0xFF2EC4B6).withOpacity(0.05)
                  : isLocked
                  ? Colors.grey[100]
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentStep && !isCompleted
                    ? const Color(0xFFFF6B35)
                    : isCompleted
                    ? const Color(0xFF2EC4B6).withOpacity(0.3)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isLocked ? 0.01 : 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number / check / lock
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF2EC4B6)
                        : isCurrentStep
                        ? const Color(0xFFFF6B35)
                        : isLocked
                        ? Colors.grey[300]
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : isLocked
                        ? Icon(Icons.lock, color: Colors.grey[500], size: 16)
                        : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrentStep ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.instructions[index],
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? Colors.grey
                              : isLocked
                              ? Colors.grey[400]
                              : Colors.black87,
                        ),
                      ),
                      // Show hint text
                      if ((isCurrentStep && !isCompleted) || isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            isCompleted
                                ? 'Tap to undo'
                                : index == widget.recipe.instructions.length - 1
                                ? 'Tap to complete final step!'
                                : 'Tap to mark complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: isCompleted
                                  ? const Color(0xFF2EC4B6).withOpacity(0.8)
                                  : const Color(0xFFFF6B35).withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Undo icon for completed steps
                if (isCompleted)
                  Icon(
                    Icons.undo,
                    color: const Color(0xFF2EC4B6).withOpacity(0.6),
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildIngredientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: widget.recipe.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = widget.recipe.ingredients[index];
        final isChecked = _ingredientChecked[index];

        return GestureDetector(
          onTap: () {
            setState(() => _ingredientChecked[index] = !isChecked);
            HapticFeedback.selectionClick();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked ? const Color(0xFF2EC4B6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? const Color(0xFF2EC4B6) : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${ingredient.quantity}${ingredient.unit != null ? ' ${ingredient.unit}' : ''} ${ingredient.name}',
                    style: TextStyle(
                      fontSize: 15,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    final allComplete = _allStepsCompleted;
    final completedCount = _stepCompleted.where((s) => s).length;
    final totalSteps = _stepCompleted.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completedCount / totalSteps,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                allComplete ? const Color(0xFF2EC4B6) : const Color(0xFFFF6B35),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),

          // Progress text
          Text(
            '$completedCount of $totalSteps steps completed',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Finish button with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: allComplete ? _finishCooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allComplete
                    ? const Color(0xFF2EC4B6)
                    : Colors.grey[300],
                foregroundColor: allComplete
                    ? Colors.white
                    : Colors.grey[500],
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: allComplete ? 4 : 0,
                shadowColor: allComplete
                    ? const Color(0xFF2EC4B6).withOpacity(0.4)
                    : Colors.transparent,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: allComplete
                    ? const Row(
                  key: ValueKey('complete'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Finish Cooking!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    : Text(
                  key: const ValueKey('incomplete'),
                  'Complete ${totalSteps - completedCount} more step${totalSteps - completedCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== COMPLETION PAGE ====================
  Widget _buildCompletionPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Celebration animation
            _buildCelebrationAnimation(),

            const SizedBox(height: 32),

            // Congrats message
            const Text(
              '🎉 Congratulations!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve completed ${widget.recipe.title}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.timer,
                    value: _formatTime(_totalSeconds - _remainingSeconds),
                    label: 'Time Spent',
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  _buildStatItem(
                    icon: Icons.check_circle,
                    value: '${_stepCompleted.where((s) => s).length}/${_stepCompleted.length}',
                    label: 'Steps Done',
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  _buildStatItem(
                    icon: Icons.local_fire_department,
                    value: '${widget.recipe.calories}',
                    label: 'Calories',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Photo section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFF6B35).withOpacity(0.1),
                    const Color(0xFFFF8C61).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Color(0xFFFF6B35),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Capture Your Creation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a photo of your dish and share\nyour cooking achievement!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_capturedPhoto != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EC4B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF2EC4B6)),
                          SizedBox(width: 8),
                          Text(
                            'Photo captured!',
                            style: TextStyle(
                              color: Color(0xFF2EC4B6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(_capturedPhoto != null ? Icons.refresh : Icons.camera_alt),
                    label: Text(_capturedPhoto != null ? 'Retake Photo' : 'Take Photo'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon!')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B35),
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationAnimation() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _completionController,
        curve: Curves.elasticOut,
      ),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2EC4B6), Color(0xFF26A69A)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2EC4B6).withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.restaurant,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Cooking Session?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Cooking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit cooking session
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}