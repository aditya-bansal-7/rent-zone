"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft, Star, CalendarCheck, Eye, EyeOff, Sparkles, Archive, CheckCircle, MapPin, Tag, Ruler, Package } from "lucide-react";
import { mockProducts, mockRentals, mockReviews } from "@/lib/mock-data";
import { formatDate, getInitials, productStatusColors, rentalStatusColors } from "@/lib/utils";

export default function ProductDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const product = mockProducts.find((p) => p.id === id) ?? mockProducts[0];
  const productRentals = mockRentals.filter((r) => r.productId === product.id);
  const productReviews = mockReviews.filter((r) => r.productId === product.id);

  return (
    <div className="space-y-5 max-w-[1200px]">
      <Link href="/products" className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-purple-600 transition-colors">
        <ArrowLeft size={15} /> Back to Products
      </Link>

      {/* Header */}
      <div className="admin-card p-6">
        <div className="flex items-start justify-between flex-wrap gap-4">
          <div className="flex items-start gap-4">
            <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-purple-100 to-violet-100 flex items-center justify-center text-4xl flex-shrink-0">
              👗
            </div>
            <div>
              <h2 className="text-xl font-bold text-gray-900">{product.name}</h2>
              <p className="text-sm text-gray-500 mt-0.5">{product.description}</p>
              <div className="flex items-center gap-2 mt-2 flex-wrap">
                <span className={`badge ${productStatusColors[product.status]}`}>{product.status}</span>
                <span className="badge badge-gray">{product.category.name}</span>
                <span className="badge badge-indigo capitalize">{product.category.type}</span>
                <span className="badge badge-gray">{product.condition.replace("_"," ")}</span>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 flex-wrap">
            <button className="btn-secondary text-xs py-1.5 gap-1.5"><Sparkles size={14} /> Feature</button>
            {product.status === "active" || product.status === "featured"
              ? <button className="btn-secondary text-xs py-1.5 gap-1.5 text-amber-600 border-amber-200 hover:bg-amber-50"><EyeOff size={14} /> Hide</button>
              : <button className="btn-secondary text-xs py-1.5 gap-1.5 text-emerald-600 border-emerald-200 hover:bg-emerald-50"><Eye size={14} /> Approve</button>
            }
            <button className="btn-secondary text-xs py-1.5 gap-1.5"><Archive size={14} /> Archive</button>
          </div>
        </div>

        {/* Details grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 pt-6 border-t border-gray-50">
          {[
            { label: "Price/Day", value: `₹${product.rentPricePerDay}`, icon: Tag },
            { label: "Size", value: product.size, icon: Ruler },
            { label: "Occasion", value: product.occasion ?? "N/A", icon: Package },
            { label: "Listed", value: formatDate(product.createdAt), icon: CalendarCheck },
          ].map((item) => (
            <div key={item.label} className="flex items-start gap-2.5">
              <item.icon size={15} className="text-gray-400 mt-0.5" />
              <div>
                <p className="text-xs text-gray-400">{item.label}</p>
                <p className="text-sm font-semibold text-gray-800 mt-0.5">{item.value}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-3 mt-4">
          {[
            { label: "Rating", value: product.rating, sub: `${product._count.reviews} reviews`, color: "text-amber-500", bg: "bg-amber-50", icon: Star },
            { label: "Rentals", value: product._count.rentals, sub: "total", color: "text-blue-600", bg: "bg-blue-50", icon: CalendarCheck },
            { label: "Reviews", value: product._count.reviews, sub: "received", color: "text-purple-600", bg: "bg-purple-50", icon: Star },
          ].map((s) => (
            <div key={s.label} className="flex items-center gap-3 p-3 rounded-xl bg-gray-50">
              <div className={`w-9 h-9 rounded-xl ${s.bg} flex items-center justify-center`}>
                <s.icon className={`w-4 h-4 ${s.color}`} />
              </div>
              <div>
                <p className="text-lg font-bold text-gray-900">{s.value}</p>
                <p className="text-xs text-gray-500">{s.label} · {s.sub}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Owner */}
      <div className="admin-card p-5">
        <p className="section-title mb-4">Owner Information</p>
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-400 to-violet-500 flex items-center justify-center text-white font-bold">
            {getInitials(product.listedBy.name)}
          </div>
          <div>
            <p className="font-semibold text-gray-800">{product.listedBy.name}</p>
            {product.listedBy.isVerified && (
              <div className="flex items-center gap-1 text-emerald-500 text-xs mt-0.5">
                <CheckCircle size={12} /> Verified seller
              </div>
            )}
          </div>
          <Link href={`/users/${product.listedByUserId}`} className="ml-auto btn-secondary text-xs py-1.5">
            View Profile
          </Link>
        </div>
      </div>

      {/* Rental History */}
      <div className="admin-card">
        <div className="px-5 py-4 border-b border-gray-50">
          <p className="section-title">Rental History ({productRentals.length})</p>
        </div>
        {productRentals.length === 0 ? (
          <div className="empty-state py-10"><p className="text-sm text-gray-400">No rentals yet</p></div>
        ) : (
          <table className="data-table">
            <thead><tr><th>Renter</th><th>Dates</th><th>Total</th><th>Status</th><th>Requested</th></tr></thead>
            <tbody>
              {productRentals.map((r) => (
                <tr key={r.id}>
                  <td className="font-medium text-gray-800">{r.rentedBy.name}</td>
                  <td className="text-gray-500 text-sm">
                    {new Date(r.startDate).toLocaleDateString("en-IN", { day:"numeric", month:"short" })} — {new Date(r.endDate).toLocaleDateString("en-IN", { day:"numeric", month:"short" })}
                  </td>
                  <td className="font-semibold text-gray-800">₹{r.totalPrice}</td>
                  <td><span className={`badge ${rentalStatusColors[r.status]}`}>{r.status}</span></td>
                  <td className="text-gray-500 text-xs">{formatDate(r.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Reviews */}
      <div className="admin-card">
        <div className="px-5 py-4 border-b border-gray-50">
          <p className="section-title">Reviews ({productReviews.length})</p>
        </div>
        {productReviews.length === 0 ? (
          <div className="empty-state py-10"><p className="text-sm text-gray-400">No reviews yet</p></div>
        ) : (
          <div className="divide-y divide-gray-50">
            {productReviews.map((review) => (
              <div key={review.id} className="px-5 py-4">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 text-xs font-bold">
                      {getInitials(review.user.name)}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-800">{review.user.name}</p>
                      <div className="flex items-center gap-0.5 mt-0.5">
                        {[...Array(5)].map((_, i) => (
                          <Star key={i} size={11} className={i < review.rating ? "text-amber-400 fill-amber-400" : "text-gray-200 fill-gray-200"} />
                        ))}
                      </div>
                    </div>
                  </div>
                  {review.isFlagged && <span className="badge badge-red">Flagged</span>}
                </div>
                <p className="text-sm text-gray-600 mt-2">{review.comment}</p>
                <p className="text-xs text-gray-400 mt-1">{formatDate(review.createdAt)}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
