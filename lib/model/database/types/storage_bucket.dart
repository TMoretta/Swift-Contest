class StorageBucket {
  final String name;

  // A private const constructor allows us to create canonicalized instances.
  const StorageBucket._(this.name);

  // Using static const fields is the idiomatic way in Dart to create
  // a type-safe enum-like class. This creates a single, constant instance
  // for each bucket name, which is efficient and safe.
  static const StorageBucket contestsImages = StorageBucket._('contests-images'); //contest_id/uuid/filename.ext
  static const StorageBucket worksImages = StorageBucket._('works-images'); //contest_id/work_id/uuid/filename.ext
  static const StorageBucket worksFiles = StorageBucket._('works-files'); //contest_id/work_id/uuid/filename.ext
  static const StorageBucket contestsRankings = StorageBucket._('contests-rankings'); //contest_id/uuid/filename.ext
}