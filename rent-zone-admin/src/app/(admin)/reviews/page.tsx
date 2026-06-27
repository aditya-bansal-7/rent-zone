"use client";

import { useState } from "react";
import { Search, Star, Flag, Trash2, ExternalLink } from "lucide-react";
import Link from "next/link";
import { mockReviews } from "@/lib/mock-data";
import { formatDate, getInitials, cn } from "@/lib/utils";
import type { Review } from "@/types";

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<Review[]>(mockReviews);
  const [search, setSearch] = useState("");
  const [ratingFilter, setRatingFilter] = useState<number | "all">("all");
  const [flaggedOnly, setFlaggedOnly] = useState(false);

  const filtered = reviews.filter((r) => {
    const q = search.toLowerCase();
    const matchSearch = r.user.name.toLowerCase().includes(q) || r.product.name.toLowerCase().includes(q) || r.comment.toLowerCase().includes(q);
    const matchRating = ratingFilter === "all" || r.rating === ratingFilter;
    const matchFlagged = !flaggedOnly || r.isFlagged;
    return matchSearch && matchRating && matchFlagged;
  });

  const handleDelete = (id: string) => setReviews((prev) => prev.filter((r) => r.id !== id));
  const handleFlag = (id: string) => setReviews((prev) => prev.map((r) => r.id === id ? { ...r, isFlagged: !r.isFlagged } : r));

  return (
    <div className="space-y-5 max-w-[1200px]">
      <div>
        <h2 className="text-xl font-bold text-gray-900">Review Moderation</h2>
        <p className="text-sm text-gray-500">{reviews.length} total reviews · {reviews.filter((r) => r.isFlagged).length} flagged</p>
      </div>

      {/* Filters */}
      <div className="admin-card p-4">
        <div className="flex flex-wrap gap-3 items-center">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input type="text" placeholder="Search by user, product or content..." value={search} onChange={(e) => setSearch(e.target.value)} className="form-input pl-9" />
          </div>
          <select value={ratingFilter} onChange={(e) => setRatingFilter(e.target.value === "all" ? "all" : Number(e.target.value))} className="form-select w-auto">
            <option value="all">All Ratings</option>
            {[5,4,3,2,1].map((r) => <option key={r} value={r}>{"⭐".repeat(r)} {r} star{r !== 1 && "s"}</option>)}
          </select>
          <label className="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked={flaggedOnly} onChange={(e) => setFlaggedOnly(e.target.checked)} className="rounded accent-purple-600" />
            <span className="text-sm text-gray-600">Flagged only</span>
          </label>
        </div>
      </div>

      {/* Review Cards */}
      <div className="grid grid-cols-1 gap-3">
        {filtered.map((review) => (
          <div key={review.id} className={cn("admin-card p-5 hover:shadow-card-hover transition-shadow", review.isFlagged && "border-l-4 border-l-red-400")}>
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-start gap-3 flex-1 min-w-0">
                <div className="w-9 h-9 rounded-full bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                  {getInitials(review.user.name)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <p className="font-semibold text-gray-800 text-sm">{review.user.name}</p>
                    <div className="flex items-center gap-0.5">
                      {[...Array(5)].map((_, i) => (
                        <Star key={i} size={13} className={i < review.rating ? "text-amber-400 fill-amber-400" : "text-gray-200 fill-gray-200"} />
                      ))}
                    </div>
                    {review.isFlagged && <span className="badge badge-red">Flagged</span>}
                  </div>
                  <p className="text-xs text-gray-400 mt-0.5">
                    on <Link href={`/products/${review.productId}`} className="text-purple-600 hover:underline">{review.product.name}</Link>
                  </p>
                  <p className="text-sm text-gray-700 mt-2">{review.comment}</p>
                  <p className="text-xs text-gray-400 mt-1.5">{formatDate(review.createdAt)}</p>
                </div>
              </div>
              <div className="flex items-center gap-1 flex-shrink-0">
                <button onClick={() => handleFlag(review.id)} className={cn("p-1.5 rounded-lg transition-colors", review.isFlagged ? "bg-red-50 text-red-500 hover:bg-red-100" : "hover:bg-amber-50 text-gray-400 hover:text-amber-500")} title={review.isFlagged ? "Unflag" : "Flag"}>
                  <Flag size={14} />
                </button>
                <Link href={`/products/${review.productId}`} className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors" title="View Product">
                  <ExternalLink size={14} />
                </Link>
                <button onClick={() => handleDelete(review.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors" title="Delete">
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="admin-card empty-state py-16">
          <div className="empty-state-icon"><Star size={24} /></div>
          <p className="text-sm font-medium text-gray-600">No reviews match your filters</p>
        </div>
      )}
    </div>
  );
}
