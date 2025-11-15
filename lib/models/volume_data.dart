import 'package:equatable/equatable.dart';

/// VolumeDataモデルクラス
/// 音量レベル、ミュート状態、タイムスタンプを保持
class VolumeData extends Equatable {
  /// 音量レベル (0-100)
  final int level;

  /// ミュート状態
  final bool isMuted;

  /// タイムスタンプ
  final DateTime timestamp;

  const VolumeData({
    required this.level,
    required this.isMuted,
    required this.timestamp,
  });

  /// コピーコンストラクタ
  VolumeData copyWith({
    int? level,
    bool? isMuted,
    DateTime? timestamp,
  }) {
    return VolumeData(
      level: level ?? this.level,
      isMuted: isMuted ?? this.isMuted,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [level, isMuted, timestamp];

  @override
  String toString() {
    return 'VolumeData(level: $level, isMuted: $isMuted, timestamp: $timestamp)';
  }
}
