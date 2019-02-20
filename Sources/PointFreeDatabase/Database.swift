import Either
import Foundation
import GitHub
import PointFreePrelude
import Prelude
import PostgreSQL
import Stripe

public struct Client {
  var addUserIdToSubscriptionId: (User.Id, Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  var createFeedRequestEvent: (FeedRequestEvent.FeedType, String, User.Id) -> EitherIO<Error, Prelude.Unit>
  var createSubscription: (Stripe.Subscription, User.Id) -> EitherIO<Error, Prelude.Unit>
  var deleteTeamInvite: (TeamInvite.Id) -> EitherIO<Error, Prelude.Unit>
  var fetchAdmins: () -> EitherIO<Error, [User]>
  var fetchEmailSettingsForUserId: (User.Id) -> EitherIO<Error, [EmailSetting]>
  var fetchEpisodeCredits: (User.Id) -> EitherIO<Error, [EpisodeCredit]>
  var fetchFreeEpisodeUsers: () -> EitherIO<Error, [User]>
  var fetchSubscriptionById: (Subscription.Id) -> EitherIO<Error, Subscription?>
  var fetchSubscriptionByOwnerId: (User.Id) -> EitherIO<Error, Subscription?>
  var fetchSubscriptionTeammatesByOwnerId: (User.Id) -> EitherIO<Error, [User]>
  var fetchTeamInvite: (TeamInvite.Id) -> EitherIO<Error, TeamInvite?>
  var fetchTeamInvites: (User.Id) -> EitherIO<Error, [TeamInvite]>
  var fetchUserByGitHub: (GitHub.User.Id) -> EitherIO<Error, User?>
  var fetchUserById: (User.Id) -> EitherIO<Error, User?>
  var fetchUsersSubscribedToNewsletter: (EmailSetting.Newsletter, Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [User]>
  var fetchUsersToWelcome: (Int) -> EitherIO<Error, [User]>
  var incrementEpisodeCredits: ([User.Id]) -> EitherIO<Error, [User]>
  var insertTeamInvite: (EmailAddress, User.Id) -> EitherIO<Error, TeamInvite>
  public var migrate: () -> EitherIO<Error, Prelude.Unit>
  var redeemEpisodeCredit: (Int, User.Id) -> EitherIO<Error, Prelude.Unit>
  var registerUser: (GitHub.UserEnvelope, EmailAddress) -> EitherIO<Error, User?>
  var removeTeammateUserIdFromSubscriptionId: (User.Id, Subscription.Id) -> EitherIO<Error, Prelude.Unit>
  var updateStripeSubscription: (Stripe.Subscription) -> EitherIO<Error, Subscription?>
  var updateUser: (User.Id, String?, EmailAddress?, [EmailSetting.Newsletter]?, Int?) -> EitherIO<Error, Prelude.Unit>
  var upsertUser: (GitHub.UserEnvelope, EmailAddress) -> EitherIO<Error, User?>
}

extension Client {
  init() {
    self.init(
      addUserIdToSubscriptionId: PointFreeDatabase.add(userId:toSubscriptionId:),
      createFeedRequestEvent: PointFreeDatabase.createFeedRequestEvent(type:userAgent:userId:),
      createSubscription: PointFreeDatabase.createSubscription,
      deleteTeamInvite: PointFreeDatabase.deleteTeamInvite,
      fetchAdmins: PointFreeDatabase.fetchAdmins,
      fetchEmailSettingsForUserId: PointFreeDatabase.fetchEmailSettings(forUserId:),
      fetchEpisodeCredits: PointFreeDatabase.fetchEpisodeCredits(for:),
      fetchFreeEpisodeUsers: PointFreeDatabase.fetchFreeEpisodeUsers,
      fetchSubscriptionById: PointFreeDatabase.fetchSubscription(id:),
      fetchSubscriptionByOwnerId: PointFreeDatabase.fetchSubscription(ownerId:),
      fetchSubscriptionTeammatesByOwnerId: PointFreeDatabase.fetchSubscriptionTeammates(ownerId:),
      fetchTeamInvite: PointFreeDatabase.fetchTeamInvite,
      fetchTeamInvites: PointFreeDatabase.fetchTeamInvites,
      fetchUserByGitHub: PointFreeDatabase.fetchUser(byGitHubUserId:),
      fetchUserById: PointFreeDatabase.fetchUser(byUserId:),
      fetchUsersSubscribedToNewsletter: PointFreeDatabase.fetchUsersSubscribed(to:nonsubscriberOrSubscriber:),
      fetchUsersToWelcome: PointFreeDatabase.fetchUsersToWelcome(fromWeeksAgo:),
      incrementEpisodeCredits: PointFreeDatabase.incrementEpisodeCredits(for:),
      insertTeamInvite: PointFreeDatabase.insertTeamInvite,
      migrate: PointFreeDatabase.migrate,
      redeemEpisodeCredit: PointFreeDatabase.redeemEpisodeCredit(episodeSequence:userId:),
      registerUser: PointFreeDatabase.registerUser(withGitHubEnvelope:email:),
      removeTeammateUserIdFromSubscriptionId: PointFreeDatabase.remove(teammateUserId:fromSubscriptionId:),
      updateStripeSubscription: PointFreeDatabase.update(stripeSubscription:),
      updateUser: PointFreeDatabase.updateUser(withId:name:email:emailSettings:episodeCreditCount:),
      upsertUser: PointFreeDatabase.upsertUser(withGitHubEnvelope:email:)
    )
  }
}

public struct EmailSetting: Codable, Equatable {
  public internal(set) var newsletter: Newsletter
  public internal(set) var userId: User.Id

  public enum CodingKeys: String, CodingKey {
    case newsletter
    case userId = "user_id"
  }

  public enum Newsletter: String, RawRepresentable, Codable, Equatable {
    case announcements
    case newBlogPost
    case newEpisode
    case welcomeEmails

    public static let allNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode,
      .welcomeEmails
    ]

    public static let subscriberNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode
    ]
  }
}

public struct EpisodeCredit: Decodable, Equatable {
  public internal(set) var episodeSequence: Int
  public internal(set) var userId: User.Id

  public enum CodingKeys: String, CodingKey {
    case episodeSequence = "episode_sequence"
    case userId = "user_id"
  }
}

public struct FeedRequestEvent: Decodable, Equatable {
  public typealias Id = Tagged<FeedRequestEvent, UUID>

  public var id: Id
  public var type: FeedType
  public var userAgent: String
  public var userId: User.Id
  public var updatedAt: Date

  public enum CodingKeys: String, CodingKey {
    case id
    case type
    case userAgent = "user_agent"
    case userId = "user_id"
    case updatedAt = "updated_at"
  }

  public enum FeedType: String, Decodable {
    case privateEpisodesFeed
  }
}

public struct User: Decodable, Equatable {
  public var email: EmailAddress
  public var episodeCreditCount: Int
  public var gitHubUserId: GitHub.User.Id
  public var gitHubAccessToken: String
  public var id: Id
  public var isAdmin: Bool
  public var name: String?
  public var rssSalt: RssSalt
  public var subscriptionId: Subscription.Id?

  public typealias Id = Tagged<User, UUID>
  public typealias RssSalt = Tagged<(User, rssSalt: ()), UUID>

  public enum CodingKeys: String, CodingKey {
    case email
    case episodeCreditCount = "episode_credit_count"
    case gitHubUserId = "github_user_id"
    case gitHubAccessToken = "github_access_token"
    case id
    case isAdmin = "is_admin"
    case name
    case rssSalt = "rss_salt"
    case subscriptionId = "subscription_id"
  }

  var displayName: String {
    return name ?? email.rawValue
  }
}

public struct Subscription: Decodable {
  public var id: Id
  public var stripeSubscriptionId: Stripe.Subscription.Id
  public var stripeSubscriptionStatus: Stripe.Subscription.Status
  public var userId: User.Id

  public typealias Id = Tagged<Subscription, UUID>

  private enum CodingKeys: String, CodingKey {
    case id
    case stripeSubscriptionId = "stripe_subscription_id"
    case stripeSubscriptionStatus = "stripe_subscription_status"
    case userId = "user_id"
  }
}

public struct TeamInvite: Decodable {
  public var createdAt: Date
  public var email: EmailAddress
  public var id: Id
  public var inviterUserId: User.Id

  public typealias Id = Tagged<TeamInvite, UUID>

  private enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
    case email
    case id
    case inviterUserId = "inviter_user_id"
  }
}

private func createFeedRequestEvent(
  type: FeedRequestEvent.FeedType,
  userAgent: String,
  userId: User.Id
  ) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    INSERT INTO "feed_request_events"
    ("type", "user_agent", "user_id")
    VALUES
    ($1, $2, $3)
    ON CONFLICT ("type", "user_agent", "user_id") DO UPDATE
    SET "count" = "feed_request_events"."count" + 1
    """,
    [
      type.rawValue,
      userAgent,
      userId.rawValue
    ]
    )
    .map(const(unit))
}

private func createSubscription(
  with stripeSubscription: Stripe.Subscription, for userId: User.Id
  )
  -> EitherIO<Error, Prelude.Unit> {
    return execute(
      """
      INSERT INTO "subscriptions" ("stripe_subscription_id", "stripe_subscription_status", "user_id")
      VALUES ($1, $2, $3)
      RETURNING "id"
      """,
      [
        stripeSubscription.id.rawValue,
        stripeSubscription.status.rawValue,
        userId.rawValue.uuidString,
        ]
      )
      .flatMap { node in
        execute(
          """
          UPDATE "users"
          SET "subscription_id" = $1
          WHERE "users"."id" = $2
          """,
          [
            node[0, "id"]?.string,
            userId.rawValue.uuidString
          ]
        )
      }
      .map(const(unit))
}

private func update(stripeSubscription: Stripe.Subscription) -> EitherIO<Error, Subscription?> {
  return firstRow(
    """
    UPDATE "subscriptions"
    SET "stripe_subscription_status" = $1
    WHERE "subscriptions"."stripe_subscription_id" = $2
    RETURNING "id", "stripe_subscription_id", "stripe_subscription_status", "user_id"
    """,
    [
      stripeSubscription.status.rawValue,
      stripeSubscription.id.rawValue
    ]
  )
}

private func add(userId: User.Id, toSubscriptionId subscriptionId: Subscription.Id) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    UPDATE "users"
    SET "subscription_id" = $1
    WHERE "users"."id" = $2
    """,
    [
      subscriptionId.rawValue.uuidString,
      userId.rawValue.uuidString,
    ]
  )
  .map(const(unit))
}

private func remove(
  teammateUserId: User.Id,
  fromSubscriptionId subscriptionId: Subscription.Id
  ) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    UPDATE "users"
    SET "subscription_id" = NULL
    WHERE "users"."id" = $1
    AND "users"."subscription_id" = $2
    """,
    [
      teammateUserId.rawValue.uuidString,
      subscriptionId.rawValue.uuidString,
      ]
    )
    .map(const(unit))
}

private func fetchSubscription(id: Subscription.Id) -> EitherIO<Error, Subscription?> {
  return firstRow(
    """
    SELECT "id", "user_id", "stripe_subscription_id", "stripe_subscription_status"
    FROM "subscriptions"
    WHERE "id" = $1
    ORDER BY "created_at" DESC
    LIMIT 1
    """,
    [id.rawValue.uuidString]
  )
}

private func fetchSubscription(ownerId: User.Id) -> EitherIO<Error, Subscription?> {
  return firstRow(
    """
    SELECT "id", "user_id", "stripe_subscription_id", "stripe_subscription_status"
    FROM "subscriptions"
    WHERE "user_id" = $1
    ORDER BY "created_at" DESC
    LIMIT 1
    """,
    [ownerId.rawValue.uuidString]
  )
}

private func fetchSubscriptionTeammates(ownerId: User.Id) -> EitherIO<Error, [User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
    FROM "users"
    INNER JOIN "subscriptions" ON "users"."subscription_id" = "subscriptions"."id"
    WHERE "subscriptions"."user_id" = $1
    """,
    [ownerId.rawValue.uuidString]
  )
}

private func updateUser(
  withId userId: User.Id,
  name: String?,
  email: EmailAddress?,
  emailSettings: [EmailSetting.Newsletter]?,
  episodeCreditCount: Int?
  ) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    UPDATE "users"
    SET "name" = COALESCE($1, "name"),
        "email" = COALESCE($2, "email"),
        "episode_credit_count" = COALESCE($3, "episode_credit_count")
    WHERE "id" = $4
    """,
    [
      name,
      email?.rawValue,
      episodeCreditCount,
      userId.rawValue.uuidString
    ]
    )
    .flatMap(const(updateEmailSettings(settings: emailSettings, forUserId: userId)))
}

// TODO: This should return a non-optional user
private func registerUser(
  withGitHubEnvelope envelope: GitHub.UserEnvelope,
  email: EmailAddress
  ) -> EitherIO<Error, User?> {

  return upsertUser(withGitHubEnvelope: envelope, email: email)
    .flatMap { optionalUser in
      guard let user = optionalUser else { return pure(optionalUser) }

      return updateEmailSettings(settings: EmailSetting.Newsletter.allNewsletters, forUserId: user.id)
        .map(const(optionalUser))
  }
}

private func updateEmailSettings(
  settings: [EmailSetting.Newsletter]?,
  forUserId userId: User.Id
  )
  -> EitherIO<Error, Prelude.Unit> {

    guard let settings = settings else { return pure(unit) }

    let deleteEmailSettings = execute(
      """
      DELETE FROM "email_settings"
      WHERE "user_id" = $1
      """,
      [userId.rawValue.uuidString]
      )
      .map(const(unit))

    let updateEmailSettings = sequence(
      settings.map { type in
        execute(
          """
          INSERT INTO "email_settings" ("newsletter", "user_id")
          VALUES ($1, $2)
          """,
          [
            type.rawValue,
            userId.rawValue.uuidString
          ]
        )
      }
    )
    .map(const(unit))

    return sequence([deleteEmailSettings, updateEmailSettings])
      .map(const(unit))
}

// TODO: This should return a non-optional user
private func upsertUser(
  withGitHubEnvelope envelope: GitHub.UserEnvelope,
  email: EmailAddress
  ) -> EitherIO<Error, User?> {

  return firstRow(
    """
    INSERT INTO "users" ("email", "github_user_id", "github_access_token", "name", "episode_credit_count")
    VALUES ($1, $2, $3, $4, 1)
    ON CONFLICT ("github_user_id") DO UPDATE
    SET "github_access_token" = $3, "name" = $4
    RETURNING *
    """,
    [
      email.rawValue,
      envelope.gitHubUser.id.rawValue,
      envelope.accessToken.accessToken,
      envelope.gitHubUser.name
    ]
  )
  .mapExcept(requireSome)
}

private func fetchUser(byUserId id: User.Id) -> EitherIO<Error, User?> {
  return firstRow(
    """
    SELECT "email",
           "episode_credit_count",
           "github_user_id",
           "github_access_token",
           "id",
           "is_admin",
           "name",
           "subscription_id",
           "rss_salt"
    FROM "users"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.rawValue.uuidString]
  )
}

private func fetchUsersSubscribed(to newsletter: EmailSetting.Newsletter, nonsubscriberOrSubscriber: Either<Prelude.Unit, Prelude.Unit>?) -> EitherIO<Error, [User]> {
  let condition: String
  switch nonsubscriberOrSubscriber {
  case .none:
    condition = ""
  case .some(.left):
    condition = " AND \"users\".\"subscription_id\" IS NULL"
  case .some(.right):
    condition = " AND \"users\".\"subscription_id\" IS NOT NULL"
  }
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
    FROM "email_settings" LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
    WHERE "email_settings"."newsletter" = $1\(condition)
    """,
    [newsletter.rawValue]
  )
}

private func fetchUsersToWelcome(fromWeeksAgo weeksAgo: Int) -> EitherIO<Error, [User]> {
  let daysAgo = weeksAgo * 7
  return rows(
    """
    SELECT
        "users"."email",
        "users"."episode_credit_count",
        "users"."github_user_id",
        "users"."github_access_token",
        "users"."id",
        "users"."is_admin",
        "users"."name",
        "users"."subscription_id",
        "users"."rss_salt"
    FROM
        "email_settings"
        LEFT JOIN "users" ON "email_settings"."user_id" = "users"."id"
        LEFT JOIN "subscriptions" on "users"."id" = "subscriptions"."user_id"
    WHERE
        "email_settings"."newsletter" = $1
        AND "users"."created_at" BETWEEN CURRENT_DATE - INTERVAL '\(daysAgo) DAY'
        AND CURRENT_DATE - INTERVAL '\(daysAgo - 1) DAY'
        AND "users"."subscription_id" IS NULL
        AND "subscriptions"."user_id" IS NULL;
    """,
    [EmailSetting.Newsletter.welcomeEmails.rawValue]
  )
}

private func incrementEpisodeCredits(for userIds: [User.Id]) -> EitherIO<Error, [User]> {
  guard !userIds.isEmpty else { return pure([]) }
  return rows(
    """
    UPDATE "users"
    SET "episode_credit_count" = "episode_credit_count" + 1
    WHERE "id" IN (\(userIds.map { "'\($0.rawValue.uuidString)'" }.joined(separator: ",")))
    RETURNING *
    """,
    []
  )
}

private func fetchUser(byGitHubUserId userId: GitHub.User.Id) -> EitherIO<Error, User?> {
  return firstRow(
    """
    SELECT "email",
           "episode_credit_count",
           "github_user_id",
           "github_access_token",
           "id",
           "is_admin",
           "name",
           "subscription_id",
           "rss_salt"
    FROM "users"
    WHERE "github_user_id" = $1
    LIMIT 1
    """,
    [userId.rawValue]
  )
}

private func fetchTeamInvite(id: TeamInvite.Id) -> EitherIO<Error, TeamInvite?> {
  return firstRow(
    """
    SELECT "created_at", "email", "id", "inviter_user_id"
    FROM "team_invites"
    WHERE "id" = $1
    LIMIT 1
    """,
    [id.rawValue.uuidString]
  )
}

private func deleteTeamInvite(id: TeamInvite.Id) -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    DELETE FROM "team_invites"
    WHERE "id" = $1
    """,
    [id.rawValue.uuidString]
  )
  .map(const(unit))
}

private func fetchTeamInvites(inviterId: User.Id) -> EitherIO<Error, [TeamInvite]> {
  return rows(
    """
    SELECT "created_at", "email", "id", "inviter_user_id"
    FROM "team_invites"
    WHERE "inviter_user_id" = $1
    """,
    [inviterId.rawValue.uuidString]
  )
}

private func fetchAdmins() -> EitherIO<Error, [User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
    FROM "users"
    WHERE "users"."is_admin" = TRUE
    """,
    []
  )
}

private func insertTeamInvite(
  email: EmailAddress,
  inviterUserId: User.Id
  ) -> EitherIO<Error, TeamInvite> {

  return firstRow(
    """
    INSERT INTO "team_invites" ("email", "inviter_user_id")
    VALUES ($1, $2)
    RETURNING *
    """,
    [
      email.rawValue,
      inviterUserId.rawValue.uuidString
    ]
    )
    .mapExcept(requireSome)
}

private func fetchEmailSettings(forUserId userId: User.Id) -> EitherIO<Error, [EmailSetting]> {

  return rows(
    """
    SELECT "newsletter", "user_id"
    FROM "email_settings"
    WHERE "user_id" = $1
    """,
    [userId.rawValue.uuidString]
  )
}

private func fetchEpisodeCredits(for userId: User.Id) -> EitherIO<Error, [EpisodeCredit]> {
  return rows(
    """
    SELECT "episode_sequence", "user_id"
    FROM "episode_credits"
    WHERE "user_id" = $1
    """,
    [userId.rawValue.uuidString]
  )
}

private func fetchFreeEpisodeUsers() -> EitherIO<Error, [User]> {
  return rows(
    """
    SELECT "users"."email",
           "users"."episode_credit_count",
           "users"."github_user_id",
           "users"."github_access_token",
           "users"."id",
           "users"."is_admin",
           "users"."name",
           "users"."subscription_id",
           "users"."rss_salt"
    FROM "users"
    LEFT JOIN "subscriptions" ON "subscriptions"."id" = "users"."subscription_id"
    LEFT JOIN "email_settings" ON "email_settings"."user_id" = "users"."id"
    WHERE (
      "subscriptions"."stripe_subscription_status" IS NULL
        OR "subscriptions"."stripe_subscription_status" != $1
    )
    AND "email_settings"."newsletter" = $2;
    """,
    [
      Stripe.Subscription.Status.active.rawValue,
      EmailSetting.Newsletter.newEpisode.rawValue
    ]
  )
}

private func redeemEpisodeCredit(episodeSequence: Int, userId: User.Id) -> EitherIO<Error, Prelude.Unit> {

  return execute(
    """
    INSERT INTO "episode_credits" ("episode_sequence", "user_id")
    VALUES ($1, $2)
    """,
    [
      episodeSequence,
      userId.rawValue.uuidString
    ]
    )
    .map(const(unit))
}

private func migrate() -> EitherIO<Error, Prelude.Unit> {
  return execute(
    """
    CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "public"
    """
    )
    .flatMap(const(execute(
      """
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "public"
      """
    )))
    .flatMap(const(execute(
      """
      CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "public"
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "users" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "email" citext NOT NULL UNIQUE,
        "github_user_id" integer UNIQUE,
        "github_access_token" character varying,
        "name" character varying,
        "subscription_id" uuid,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "updated_at" timestamp without time zone
      )
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "subscriptions" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL,
        "stripe_subscription_id" character varying NOT NULL,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "updated_at" timestamp without time zone
      );
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "team_invites" (
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL,
        "email" character varying,
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "inviter_user_id" uuid REFERENCES "users" ("id") NOT NULL
      )
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "email_settings" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "newsletter" character varying,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL
      )
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "subscriptions"
      ADD COLUMN IF NOT EXISTS
      "stripe_subscription_status" character varying NOT NULL DEFAULT 'active'
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS
      "is_admin" boolean NOT NULL DEFAULT FALSE
      """
    )))
    .flatMap(const(execute(
      """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_subscriptions_on_stripe_subscription_id"
      ON "subscriptions" ("stripe_subscription_id")
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "episode_credits" (
        "episode_sequence" integer,
        "user_id" uuid REFERENCES "users" ("id") NOT NULL
      )
      """
    )))
    .flatMap(const(execute(
      """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_episode_credits_on_episode_sequence_and_user_id"
      ON "episode_credits" ("episode_sequence", "user_id")
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS
      "episode_credit_count" integer NOT NULL DEFAULT 0
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "episode_credits"
      ADD COLUMN IF NOT EXISTS
      "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS
      "rss_salt" uuid DEFAULT uuid_generate_v1mc() NOT NULL
      """
    )))
    .flatMap(const(execute(
      """
      CREATE TABLE IF NOT EXISTS "feed_request_events" (
        "id" uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY NOT NULL,
        "type" character varying NOT NULL,
        "user_agent" character varying NOT NULL,
        "user_id" uuid REFERENCES "users" ("id"),
        "count" integer NOT NULL DEFAULT 1,
        "created_at" timestamp without time zone DEFAULT NOW() NOT NULL
      )
      """
    )))
    .flatMap(const(execute(
      """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_feed_request_events_on_type_user_agent_user_id"
      ON "feed_request_events" ("type", "user_agent", "user_id")
      """
    )))
    .flatMap(const(execute(
      """
      ALTER TABLE "feed_request_events"
      ADD COLUMN IF NOT EXISTS
      "updated_at" timestamp without time zone DEFAULT NOW() NOT NULL
      """
    )))
    .flatMap(const(execute(
      """
      CREATE UNIQUE INDEX IF NOT EXISTS "index_email_settings_on_newsletter_user_id"
      ON "email_settings" ("newsletter", "user_id")
      """
    )))
    .flatMap(const(execute(
      """
      CREATE OR REPLACE FUNCTION update_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW."updated_at" = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE PLPGSQL;
      """
    )))
    .flatMap(const(execute(
      """
      DO $$
      DECLARE
        "table" text;
      BEGIN
        FOR "table" IN
          SELECT "table_name" FROM "information_schema"."columns"
          WHERE column_name = 'updated_at'
        LOOP
          IF NOT EXISTS (
            SELECT 1 FROM "information_schema"."triggers"
            WHERE "trigger_name" = 'update_updated_at_' || "table"
          ) THEN
            EXECUTE format(
              '
              CREATE TRIGGER "update_updated_at_%I"
              BEFORE UPDATE ON "%I"
              FOR EACH ROW EXECUTE PROCEDURE update_updated_at()
              ',
              "table", "table"
            );
          END IF;
        END LOOP;
      END;
      $$ LANGUAGE PLPGSQL;
      """
    )))
    .map(const(unit))
}

public enum DatabaseError: Error {
  case invalidUrl
}

private let connInfo: Either<Error, PostgreSQL.ConnInfo> =
//  URLComponents(string: Current.envVars.postgres.databaseUrl)
//  .flatMap { url -> PostgreSQL.ConnInfo? in
//    curry(PostgreSQL.ConnInfo.basic)
//      <¢> url.host
//      <*> url.port
//      <*> String(url.path.dropFirst())
//      <*> url.user
//      <*> url.password
//  }
//  .map(Either.right)
//  ??
  .left(DatabaseError.invalidUrl as Error)

private let postgres = lift(connInfo)
  .flatMap(EitherIO.init <<< IO.wrap(Either.wrap(PostgreSQL.Database.init)))

private let conn = postgres
  .flatMap { db in .wrap(db.makeConnection) }

private func rows<T: Decodable>(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, [T]> {

    return execute(query, representable)
      .flatMap { node in
        EitherIO.wrap {
          try DatabaseDecoder().decode([T].self, from: node)
        }
    }
}

private func firstRow<T: Decodable>(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, T?> {

    return rows(query, representable)
      .map(^\.first)
}

// public let execute = EitherIO.init <<< IO.wrap(Either.wrap(conn.execute))
func execute(_ query: String, _ representable: [PostgreSQL.NodeRepresentable] = [])
  -> EitherIO<Error, PostgreSQL.Node> {

    fatalError()
//    return conn.flatMap { conn in
//      return .wrap { () -> Node in
//        let uuid = UUID().uuidString
//        let startTime = Current.date().timeIntervalSince1970
//        Current.logger.debug("[DB] \(uuid) \(query)")
//        let result = try conn.execute(query, representable)
//        let endTime = Current.date().timeIntervalSince1970
//        let delta = Int((endTime - startTime) * 1000)
//        Current.logger.debug("[DB] \(uuid) \(delta)ms")
//        return result
//      }
//    }
}