import {
  AfterLoad,
  BeforeInsert,
  BeforeUpdate,
  Column,
  CreateDateColumn,
  Entity,
  JoinTable,
  ManyToMany,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from "typeorm";
import { string_to_slug } from "../utils/stringToSlug";
import Comment from "./Comment";
import Tag from "./Tag";
import User from "./User";

@Entity()
class Article {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column()
  slug: string;

  @Column()
  description: string;

  @Column()
  body: string;

  @ManyToMany(() => Tag, (tag) => tag.articles, { cascade: true })
  @JoinTable()
  tagList: Tag[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.articles)
  author: User;

  @ManyToMany(() => User, (user) => user.favorited, { cascade: true })
  @JoinTable()
  favorited: User[];

  @OneToMany(() => Comment, (comment) => comment.article)
  comments: Comment[];

  favoritesCount: number;

  @AfterLoad()
  updateFavoriteCount() {
    this.favoritesCount =
      this.favorited === undefined ? 0 : this.favorited.length;
  }

  @BeforeInsert()
  @BeforeUpdate()
  @AfterLoad()
  beforeInsertActions() {
    this.slug = string_to_slug(this.title);
    this.favoritesCount =
      this.favorited === undefined ? 0 : this.favorited.length;
  }
}

export default Article;
