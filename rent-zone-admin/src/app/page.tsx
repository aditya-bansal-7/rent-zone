import Link from "next/link";
import {
  ArrowDownRight,
  ArrowRight,
  BarChart3,
  CalendarDays,
  Check,
  CircleCheck,
  LayoutDashboard,
  Package,
  ShieldCheck,
  ShirtIcon,
  Sparkles,
  Users,
} from "lucide-react";

const highlights = [
  {
    icon: ShieldCheck,
    title: "Keep the community safe",
    description:
      "Review listings, verify members, and resolve reports from one thoughtful workspace.",
  },
  {
    icon: CalendarDays,
    title: "Stay on top of every rental",
    description:
      "Follow bookings from request to return, with the details your team needs in reach.",
  },
  {
    icon: BarChart3,
    title: "See the whole picture",
    description:
      "Turn marketplace activity into clear signals about growth, revenue, and engagement.",
  },
];

export default function Home() {
  return (
    <main className="min-h-screen overflow-hidden bg-[#fbfaff] text-[#211936]">
      <header className="relative z-10 border-b border-[#eeeaf5] bg-white/80 backdrop-blur-xl">
        <div className="mx-auto flex h-[76px] max-w-7xl items-center justify-between px-5 sm:px-8">
          <Link href="/" className="flex items-center gap-3" aria-label="Rent Zone home">
            <span className="flex h-10 w-10 items-center justify-center rounded-[14px] bg-gradient-to-br from-[#8b5cf6] to-[#6d36d8] text-white shadow-lg shadow-violet-200/70">
              <ShirtIcon size={20} strokeWidth={2.2} />
            </span>
            <span>
              <span className="block text-[15px] font-bold leading-tight tracking-[-0.03em]">
                Rent Zone
              </span>
              <span className="mt-0.5 block text-[10px] font-semibold uppercase tracking-[0.16em] text-[#8c829e]">
                Marketplace studio
              </span>
            </span>
          </Link>

          <nav className="hidden items-center gap-8 md:flex" aria-label="Main navigation">
            <Link href="#platform" className="text-sm font-medium text-[#716a80] transition hover:text-[#7139db]">
              Platform
            </Link>
            <Link href="#operations" className="text-sm font-medium text-[#716a80] transition hover:text-[#7139db]">
              Operations
            </Link>
            <Link href="#about" className="text-sm font-medium text-[#716a80] transition hover:text-[#7139db]">
              About
            </Link>
          </nav>

          <Link
            href="/login"
            className="inline-flex items-center gap-2 rounded-full bg-[#211936] px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-[#39285b]"
          >
            Sign in <ArrowRight size={15} />
          </Link>
        </div>
      </header>

      <section className="relative mx-auto grid max-w-7xl items-center gap-14 px-5 pb-20 pt-16 sm:px-8 sm:pt-24 lg:grid-cols-[0.92fr_1.08fr] lg:gap-10 lg:pb-28 lg:pt-24">
        <div className="pointer-events-none absolute -left-56 top-20 h-[480px] w-[480px] rounded-full bg-violet-200/40 blur-[110px]" />
        <div className="pointer-events-none absolute right-[-130px] top-12 h-[550px] w-[550px] rounded-full bg-fuchsia-100/70 blur-[120px]" />

        <div className="relative z-[1]">
          <div className="mb-7 inline-flex items-center gap-2 rounded-full border border-[#e9e1f7] bg-white/80 px-3.5 py-2 text-xs font-semibold text-[#6d3ac4] shadow-sm">
            <Sparkles size={14} />
            The home of Rent Zone operations
          </div>
          <h1 className="max-w-[640px] text-[clamp(3rem,6.1vw,5.25rem)] font-semibold leading-[0.99] tracking-[-0.075em] text-[#211936]">
            Make room for
            <span className="block bg-gradient-to-r from-[#8e5cf6] via-[#7747df] to-[#b353cf] bg-clip-text pb-2 text-transparent">
              better renting.
            </span>
          </h1>
          <p className="mt-6 max-w-[510px] text-[16px] leading-7 text-[#716a80] sm:text-[17px]">
            A calmer way to run a more connected fashion rental marketplace.
            Bring your people, listings, bookings, and insights together in one
            beautifully considered workspace.
          </p>

          <div className="mt-9 flex flex-wrap items-center gap-3">
            <Link
              href="/login"
              className="inline-flex items-center gap-2.5 rounded-full bg-gradient-to-r from-[#8250e8] to-[#713bd7] px-6 py-3.5 text-sm font-semibold text-white shadow-lg shadow-violet-300/50 transition hover:-translate-y-0.5 hover:shadow-xl hover:shadow-violet-300/60"
            >
              Open your workspace <ArrowRight size={16} />
            </Link>
            <Link
              href="#platform"
              className="inline-flex items-center gap-2 rounded-full px-5 py-3.5 text-sm font-semibold text-[#524962] transition hover:bg-white"
            >
              Discover the platform <ArrowDownRight size={16} />
            </Link>
          </div>

          <div className="mt-10 flex flex-wrap items-center gap-x-6 gap-y-3 text-xs font-medium text-[#81788f]">
            <span className="inline-flex items-center gap-2">
              <CircleCheck size={15} className="text-[#7750d2]" /> Built around circular fashion
            </span>
            <span className="inline-flex items-center gap-2">
              <CircleCheck size={15} className="text-[#7750d2]" /> One connected platform
            </span>
          </div>
        </div>

        <div className="relative z-[1] mx-auto w-full max-w-[620px] lg:mr-0">
          <div className="absolute -right-5 -top-8 h-28 w-28 rounded-full border border-[#dfd4f1] sm:-right-8 sm:-top-10 sm:h-36 sm:w-36" />
          <div className="absolute -bottom-8 -left-8 h-32 w-32 rounded-full bg-[#eee8fa] sm:-bottom-10 sm:-left-10 sm:h-40 sm:w-40" />

          <div className="relative overflow-hidden rounded-[26px] border border-white/80 bg-white p-3 shadow-[0_35px_100px_-45px_rgba(70,43,112,0.42)] sm:rounded-[30px] sm:p-4">
            <div className="overflow-hidden rounded-[19px] border border-[#f0edf5] bg-[#fbfaff]">
              <div className="flex items-center justify-between border-b border-[#f0edf5] bg-white px-4 py-3.5 sm:px-6">
                <div className="flex items-center gap-2.5">
                  <span className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#f0eafe] text-[#7747dc]">
                    <LayoutDashboard size={16} />
                  </span>
                  <div>
                    <p className="text-xs font-bold text-[#2a2239]">Workspace overview</p>
                    <p className="mt-0.5 text-[10px] text-[#9b93a7]">Tuesday, May 21</p>
                  </div>
                </div>
                <div className="flex items-center gap-1.5 rounded-full bg-[#effaf4] px-2.5 py-1 text-[10px] font-semibold text-[#309262]">
                  <span className="h-1.5 w-1.5 rounded-full bg-[#42bc81]" /> All systems healthy
                </div>
              </div>

              <div className="p-4 sm:p-6">
                <div className="mb-4 flex items-end justify-between">
                  <div>
                    <p className="text-[11px] font-medium text-[#8c8498]">A little look at your marketplace</p>
                    <h2 className="mt-1 text-lg font-semibold tracking-[-0.04em] text-[#2a2239] sm:text-xl">
                      Good things are in motion.
                    </h2>
                  </div>
                  <span className="hidden rounded-lg border border-[#eeeaf5] bg-white px-2.5 py-1.5 text-[10px] font-semibold text-[#81788f] sm:block">
                    This month
                  </span>
                </div>

                <div className="grid grid-cols-3 gap-2.5 sm:gap-3">
                  {[
                    { icon: Users, label: "Community", value: "2,840", change: "+12.8%" },
                    { icon: Package, label: "Pieces to rent", value: "1,260", change: "+8.4%" },
                    { icon: CalendarDays, label: "Bookings", value: "384", change: "+16.2%" },
                  ].map(({ icon: Icon, label, value, change }) => (
                    <div key={label} className="min-w-0 rounded-2xl border border-[#f0edf5] bg-white p-3 sm:p-4">
                      <div className="flex items-center justify-between gap-1">
                        <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#f4effe] text-[#8054dc]">
                          <Icon size={14} />
                        </span>
                        <span className="hidden text-[9px] font-semibold text-[#42a879] sm:inline">{change}</span>
                      </div>
                      <p className="mt-3 truncate text-base font-bold tracking-[-0.03em] text-[#2a2239] sm:text-xl">
                        {value}
                      </p>
                      <p className="mt-0.5 truncate text-[9px] font-medium text-[#938b9f] sm:text-[10px]">{label}</p>
                    </div>
                  ))}
                </div>

                <div className="mt-3 grid gap-3 sm:grid-cols-[1.25fr_0.75fr]">
                  <div className="rounded-2xl border border-[#f0edf5] bg-white p-4">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-[11px] font-semibold text-[#42394f]">Marketplace momentum</p>
                        <p className="mt-1 text-[9px] text-[#9b93a7]">New bookings, last 7 days</p>
                      </div>
                      <span className="text-[10px] font-semibold text-[#7950d2]">+18.6%</span>
                    </div>
                    <div className="mt-4 flex h-[88px] items-end gap-2 border-b border-[#f0edf5] px-1">
                      {[35, 48, 41, 66, 54, 75, 62, 92, 72, 100, 79, 88, 68, 96].map((height, index) => (
                        <span
                          key={index}
                          className={`flex-1 rounded-t-[4px] ${index === 9 ? "bg-[#8b5ce8]" : "bg-[#e6dcfa]"}`}
                          style={{ height: `${height}%` }}
                        />
                      ))}
                    </div>
                    <div className="mt-2 flex justify-between text-[9px] text-[#a19aaa]">
                      <span>May 15</span><span>May 18</span><span>May 21</span>
                    </div>
                  </div>

                  <div className="rounded-2xl bg-gradient-to-br from-[#7950d8] to-[#5c35af] p-4 text-white">
                    <div className="flex items-center justify-between">
                      <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-white/15">
                        <Sparkles size={14} />
                      </span>
                      <span className="text-[9px] font-medium text-white/65">YOUR NEXT STEP</span>
                    </div>
                    <p className="mt-4 text-[13px] font-semibold leading-5">Your community is growing.</p>
                    <p className="mt-1.5 text-[10px] leading-4 text-white/70">
                      18 new members joined this week. Take a moment to welcome them.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[10px] font-semibold">
                      View members <ArrowRight size={12} />
                    </span>
                  </div>
                </div>

                <div className="mt-3 flex items-center justify-between rounded-xl border border-[#f0edf5] bg-white px-3.5 py-3">
                  <div className="flex items-center gap-2.5">
                    <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#eef9f3] text-[#3b9b6c]">
                      <Check size={14} />
                    </span>
                    <div>
                      <p className="text-[10px] font-semibold text-[#3b3448]">Your marketplace is looking good</p>
                      <p className="mt-0.5 text-[9px] text-[#a19aaa]">Everything important, all in one place.</p>
                    </div>
                  </div>
                  <ArrowRight size={14} className="text-[#aaa2b5]" />
                </div>
              </div>
            </div>
          </div>
          <div className="absolute -right-3 top-[44%] hidden rounded-2xl border border-white/80 bg-white px-4 py-3 shadow-xl shadow-[#5b3b8c]/10 sm:block">
            <div className="flex items-center gap-2.5">
              <span className="flex h-8 w-8 items-center justify-center rounded-xl bg-[#fff4e7] text-[#da8d32]">
                <Sparkles size={15} />
              </span>
              <div>
                <p className="text-[10px] font-semibold text-[#3b3448]">Good things, shared</p>
                <p className="mt-0.5 text-[9px] text-[#958c9e]">Fashion with another life</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="platform" className="border-y border-[#eeeaf5] bg-white">
        <div className="mx-auto grid max-w-7xl gap-8 px-5 py-8 sm:grid-cols-3 sm:px-8 lg:py-10">
          {[
            ["One place", "for marketplace operations"],
            ["Every detail", "connected to the bigger picture"],
            ["More possibility", "for fashion worth sharing"],
          ].map(([title, detail], index) => (
            <div key={title} className="flex items-start gap-4 sm:justify-center">
              <span className="pt-0.5 text-xs font-semibold text-[#a18bbf]">0{index + 1}</span>
              <p className="text-sm font-semibold text-[#342a46]">
                {title}<span className="ml-1 font-normal text-[#8a8295]">{detail}</span>
              </p>
            </div>
          ))}
        </div>
      </section>

      <section id="operations" className="mx-auto max-w-7xl px-5 py-20 sm:px-8 sm:py-28">
        <div className="mx-auto max-w-2xl text-center">
          <span className="text-xs font-bold uppercase tracking-[0.18em] text-[#8054dc]">Made for the way you work</span>
          <h2 className="mt-4 text-3xl font-semibold tracking-[-0.055em] text-[#211936] sm:text-4xl">
            The details that keep it all moving.
          </h2>
          <p className="mt-4 text-[15px] leading-7 text-[#7b7289]">
            Rent Zone brings the everyday work of a rental marketplace into one
            clear, connected place.
          </p>
        </div>

        <div className="mt-12 grid gap-4 md:grid-cols-3">
          {highlights.map(({ icon: Icon, title, description }, index) => (
            <article
              key={title}
              className="group rounded-[24px] border border-[#eeeaf5] bg-white p-7 transition duration-300 hover:-translate-y-1 hover:border-[#dfd2f6] hover:shadow-[0_20px_60px_-38px_rgba(83,51,138,0.36)]"
            >
              <span className={`flex h-12 w-12 items-center justify-center rounded-2xl ${index === 1 ? "bg-[#fff4e7] text-[#d68b37]" : "bg-[#f2edfc] text-[#7950d8]"}`}>
                <Icon size={21} />
              </span>
              <h3 className="mt-6 text-lg font-semibold tracking-[-0.03em] text-[#302641]">{title}</h3>
              <p className="mt-2 text-sm leading-6 text-[#81788f]">{description}</p>
              <Link
                href="/login"
                className="mt-6 inline-flex items-center gap-2 text-xs font-semibold text-[#7547d1] transition group-hover:gap-3"
              >
                Explore your workspace <ArrowRight size={14} />
              </Link>
            </article>
          ))}
        </div>
      </section>

      <section id="about" className="px-5 pb-20 sm:px-8 sm:pb-28">
        <div className="relative mx-auto max-w-7xl overflow-hidden rounded-[28px] bg-[#211936] px-7 py-12 sm:px-12 sm:py-14 lg:px-16">
          <div className="pointer-events-none absolute -right-12 -top-36 h-80 w-80 rounded-full bg-[#8452dc]/40 blur-[80px]" />
          <div className="pointer-events-none absolute bottom-[-170px] left-[42%] h-72 w-72 rounded-full bg-[#a84ea9]/30 blur-[80px]" />
          <div className="relative flex flex-col items-start justify-between gap-8 md:flex-row md:items-center">
            <div className="max-w-xl">
              <span className="text-xs font-semibold uppercase tracking-[0.17em] text-[#c5a9ff]">Your next chapter starts here</span>
              <h2 className="mt-4 text-3xl font-semibold leading-tight tracking-[-0.055em] text-white sm:text-[40px]">
                A little more connected. A lot more possible.
              </h2>
              <p className="mt-3 max-w-lg text-sm leading-6 text-white/65">
                Step into the Rent Zone workspace and see your marketplace from a whole new angle.
              </p>
            </div>
            <Link
              href="/login"
              className="inline-flex shrink-0 items-center gap-2.5 rounded-full bg-white px-6 py-3.5 text-sm font-semibold text-[#55358f] transition hover:bg-[#f4edff]"
            >
              Sign in to Rent Zone <ArrowRight size={16} />
            </Link>
          </div>
        </div>
      </section>

      <footer className="border-t border-[#eeeaf5] bg-white">
        <div className="mx-auto flex max-w-7xl flex-col gap-4 px-5 py-6 text-xs text-[#8e869b] sm:flex-row sm:items-center sm:justify-between sm:px-8">
          <Link href="/" className="inline-flex items-center gap-2 font-semibold text-[#514761]">
            <ShirtIcon size={15} className="text-[#7950d8]" /> Rent Zone
          </Link>
          <p>Thoughtful rentals. A more connected way to dress.</p>
          <span>© {new Date().getFullYear()} Rent Zone</span>
        </div>
      </footer>
    </main>
  );
}
