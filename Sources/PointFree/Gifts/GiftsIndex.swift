import HttpPipeline
import Foundation
import Views
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let giftsIndexMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, Route, SubscriberState>,
  Data
>
= writeStatus(.ok)
>=> map(lower)
>>> respond(
  view: giftsLanding(episodeStats:),
  layoutData: { currentUser, currentRoute, subscriberState in
    let episodeStats = stats(forEpisodes: Current.episodes())

    return SimplePageLayoutData(
      currentRoute: currentRoute,
      currentSubscriberState: subscriberState,
      currentUser: currentUser,
      data: episodeStats,
      description: """
        Give the gift of Point-Free! Purchase a 3, 6, or 12 month subscription for a friend or loved one.
        """,
      extraStyles: extraGiftLandingStyles <> testimonialStyle,
      style: .base(.some(.minimal(.black))),
      title: "🎁 Gift Subscription"
    )
  }
)