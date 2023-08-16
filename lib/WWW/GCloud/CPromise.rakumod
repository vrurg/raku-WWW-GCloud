use v6.e.PREVIEW;
# "Conditional" Promise with methods `andthen` and `orelse`
unit role WWW::GCloud::CPromise;

method then(&) {
    nextsame()
}

method andthen(&code) {
    self.then: {
        .status == Kept
            ?? code($_)
            !! .cause.rethrow
    }
}

method orelse(&code) {
    self.then: {
        .status == Broken
            ?? code($_)
            !! .result
    }
}